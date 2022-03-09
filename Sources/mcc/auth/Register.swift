//
//  RegisterCommand.swift
//
//
//  Created by Finn Behrens on 02.03.22.
//

import AnyCodable
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

        mutating func register(logger: Logger, client: MatrixClient) async throws -> MatrixRegister {
            let register = try await client.register(password: password!, username: userID, bind_email: false)
            switch register {
            case let .success(matrixRegister):
                return matrixRegister
            case let .interactive(matrixInteractiveAuth):
                session = matrixInteractiveAuth.session

                logger.debug("uninished stages: \(matrixInteractiveAuth.notCompletedStages)")
                guard let (nextStage, nextStageParams) = matrixInteractiveAuth.nextStageWithParams else {
                    abort() // TODO: throw some kind of error
                }
                logger.info("next stage: \(nextStage)")
                logger.debug("next stage params: \(String(describing: nextStageParams))")
                try await doStage(logger: logger, stage: nextStage, params: nextStageParams)
                abort()
            }
        }

        func doStage(logger: Logger, stage: String, params: AnyCodable?) async throws -> [String: AnyCodable] {
            var ret: [String: AnyCodable] = [:]
            ret["type"] = "m.login.recaptcha"
            if let session = session {
                ret["session"] = AnyCodable(stringLiteral: session)
            }

            switch stage {
            case "m.login.recaptcha":
                ret.merge(try await doRecaptcha(logger: logger, params: params)) { current, _ in current }

            default:
                print("not implemented: \(stage)")
            }

            return ret
        }

        func doRecaptcha(logger: Logger, params: AnyCodable?) async throws -> [String: AnyCodable] {
            guard let params = params,
                  let params = params.value as? [String: Any],
                  let publicKey = params["public_key"] as? String
            else {
                throw MatrixError.NotFound
            }
            logger.debug("recaptcha: public key: \(publicKey)")
            return [:]
        }
    }
}
