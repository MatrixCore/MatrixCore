//
//  Register+Recaptcha.swift
//
//
//  Created by Finn Behrens on 09.03.22.
//

import AnyCodable
import AppKit
import Foundation
import MatrixClient
import os
import Swifter

extension Mcc.Auth.Register {
    func doRecaptcha(logger: os.Logger, params: AnyCodable?) async throws -> MatrixInteractiveAuthResponse {
        guard let params = params,
              let params = params.value as? [String: Any],
              let publicKey = params["public_key"] as? String
        else {
            logger
                .warning(
                    "Missing captcha public key in homeserver configuration. Please report this to your homeserver administrator."
                )
            throw MatrixError.NotFound
        }
        logger.debug("recaptcha: public key: \(publicKey)")

        let token = try startRecaptchaServer(logger: logger, sitekey: publicKey)
        logger.debug("recaptcha: got token")
        return MatrixInteractiveAuthResponse(recaptchaResponse: token, session: session)
    }

    func startRecaptchaServer(logger _: Logger, sitekey: String) throws -> String {
        var token = ""
        let semaphore = DispatchSemaphore(value: 0)

        let server = HttpServer()

        server["/"] = { _ in .ok(.html(recaptchaHTML(sitekey: sitekey))) }

        server["/callback"] = { request in
            let data = Data(request.body)
            let dataStr = String(data: data, encoding: .utf8)
            token = dataStr!.trimmingCharacters(in: .whitespacesAndNewlines)

            semaphore.signal()
            return HttpResponse.ok(.htmlBody("OK"))
        }

        try server.start()

        let port = try server.port()
        let url = URL(string: "http://localhost:\(port)")!
        print("please open \(url) to solve the captcha")
        NSWorkspace.shared.open(url)

        semaphore.wait()
        // make sure the server had time to write the answer
        usleep(100)
        server.stop()

        return token
    }

    func recaptchaHTML(sitekey: String) -> String {
        """
        <html>
        <head>
        <title>reCAPTCHA: mcc matrix cli</title>
        <script type="text/javascript">
        var verifyCallback = function(response) {
          console.log(response)
          fetch("/callback", {
            method: "POST",
            headers: {'Content-Type': 'application/text'},
            body: response
          }).then(res => {
            console.log("Request completed! response: ", res);
          });
        };
        var onloadCallback = function() {
          grecaptcha.render('recaptcha_widget', {
            'sitekey' : "\(sitekey)",
            'callback': verifyCallback
          });
        };

        </script>
        </head>
        <body>
          <div id="recaptcha_widget"></div>
          <script src="https://www.recaptcha.net/recaptcha/api.js?onload=onloadCallback&render=explicit" async defer></script>
        </body>
        </html>
        """
    }
}
