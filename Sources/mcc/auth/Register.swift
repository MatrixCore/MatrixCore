//
//  RegisterCommand.swift
//
//
//  Created by Finn Behrens on 02.03.22.
//

import AnyCodable
import AppKit
import ArgumentParser
import Foundation
import MatrixClient
import os

extension Mcc.Auth {
    struct Register: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "register",
            abstract: "Register a new user"
        )

        @Option(name: .long, help: "The homeserver to use.")
        var homeserver: String

        @Option(name: .shortAndLong, help: "user id to use")
        var userID: String?

        @Option(name: .shortAndLong, help: "password to use")
        var password: String?

        /// Session key for interactive login
        var session: String?

        mutating func run() async throws {
            let logger = Logger()
            let client = await MatrixClient(homeserver: try MatrixHomeserver(resolve: homeserver))

            logger.debug("homserver resolved url: \(client.homeserver.url)")

            let info = try await client.getVersions()
            logger.debug("server has versions: \(info.versions)")

            if password == nil {
                var buf = [CChar](repeating: 0, count: 8192)
                guard let passphrase = readpassphrase("Enter passphrase: ", &buf, buf.count, 0),
                      let passphraseStr = String(validatingUTF8: passphrase)
                else {
                    logger.warning("Could not read password.")
                    return
                }
                password = passphraseStr
            }

            let register = try await register(logger: logger, client: client)

            print()
            print(register)
        }

        mutating func register(logger: Logger, client: MatrixClient, auth: MatrixInteractiveAuthResponse? = nil) async throws -> MatrixRegister {
            let register = try await client.register(password: password!, username: userID, auth: auth, bind_email: false)
            switch register {
            case let .success(matrixRegister):
                return matrixRegister
            case let .interactive(matrixInteractiveAuth):
                session = matrixInteractiveAuth.session

                logger.debug("completed stages: \(matrixInteractiveAuth.completed ?? [])")
                logger.debug("unfinished stages: \(matrixInteractiveAuth.notCompletedStages)")
                guard let (nextStage, nextStageParams) = matrixInteractiveAuth.nextStageWithParams else {
                    abort() // TODO: throw some kind of error
                }
                logger.info("next stage: \(nextStage.rawValue)")
                logger.debug("next stage params: \(String(describing: nextStageParams))")
                let auth = try await doStage(logger: logger, stage: nextStage, params: nextStageParams, client: client)
                return try await self.register(logger: logger, client: client, auth: auth)
            }
        }

        func doStage(logger: Logger, stage: MatrixLoginFlow, params: AnyCodable?, client: MatrixClient) async throws -> MatrixInteractiveAuthResponse {
            switch stage {
            case MatrixLoginFlow.recaptcha:
                return try await doRecaptcha(logger: logger, params: params)
            case MatrixLoginFlow.terms:
                return try await doTerms(logger: logger, params: params)
            case MatrixLoginFlow.email:
                return try await doEmail(logger: logger, params: params, client: client)

            default:
                print("not implemented: \(stage)")
            }

            throw MatrixError.NotFound // TODO: better error
        }

        func doTerms(logger: Logger, params: AnyCodable?) async throws -> MatrixInteractiveAuthResponse {
            guard let params = params,
                  let params = params.value as? [String: Any],
                  let policies = params["policies"] as? [String: Any],
                  let privacy_policy = policies["privacy_policy"] as? [String: Any],
                  let privacy_policy_en = privacy_policy["en"] as? [String: Any],
                  let urlStr = privacy_policy_en["url"] as? String,
                  let url = URL(string: urlStr),
                  let name = privacy_policy_en["name"] as? String
            else {
                logger.warning("Missing policy homeserver configuration. Please report this to your homeserver administrator.")
                throw MatrixError.NotFound
            }

            print("Pleace accept the \(name).")
            print(url)
            print()
            print("Please enter Y to accept.")

            NSWorkspace.shared.open(url)

            let input = (readLine(strippingNewline: true) ?? "").lowercased()

            let a = input.prefix(1)

            if a == "y" {
                return MatrixInteractiveAuthResponse(session: session, type: .terms)
            } else {
                abort()
            }
        }

        func doEmail(logger _: Logger, params _: AnyCodable?, client: MatrixClient) async throws -> MatrixInteractiveAuthResponse {
            let wellKnown = try await client.getWellKnown()
            let identityServer = wellKnown.identityServerBaseUrl

            abort()
        }
    }
}
