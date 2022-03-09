//
//  Auth.swift
//
//
//  Created by Finn Behrens on 02.03.22.
//

import ArgumentParser
import Foundation
import MatrixClient
import os

extension Mcc {
    struct Auth: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "auth",
            abstract: "Auth helpers",
            subcommands: [Show.self, Login.self, Register.self]
        )
    }
}

extension Mcc.Auth {
    struct Show: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "show",
            abstract: "Show information about home server"
        )

        // Does not use the Options struct, becaues userid is optional for this

        @Option(name: .long, help: "The homeserver to use.")
        var homeserver: String

        @Argument(help: "What to show")
        var what: String

        func run() async throws {
            let logger = Logger()
            let client = await MatrixClient(homeserver: try MatrixHomeserver(resolve: homeserver))

            logger.debug("homserver resolved url: \(client.homeserver.url)")

            let info = try await client.getVersions()
            logger.debug("server has versions: \(info.versions)")

            switch what {
            case "flows":
                try await loginFlows(logger: logger, client: client)
            case "register_flows":
                try await registerFlows(logger: logger, client: client)
            default:
                print("Unknown target")
            }
        }

        func loginFlows(logger _: Logger, client: MatrixClient) async throws {
            let flows = try await client.getLoginFlows()
            dump(flows)
        }

        func registerFlows(logger _: Logger, client: MatrixClient) async throws {
            let flows = try await client.getRegisterFlows()
            dump(flows)
        }
    }
}
