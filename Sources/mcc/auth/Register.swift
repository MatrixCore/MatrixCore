//
//  RegisterCommand.swift
//  
//
//  Created by Finn Behrens on 02.03.22.
//

import Foundation
import ArgumentParser
import MatrixClient
import os


extension Mcc.Auth {
    struct Register: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "register",
            abstract: "Register a new user"
        )
        
        @OptionGroup var options: Options
        
        func run() async throws {
            let logger = Logger.init()
            let client = await MatrixClient(homeserver: try MatrixHomeserver(resolve: options.homeserver))
            
            logger.debug("homserver resolved url: \(client.homeserver.url)")
            
            let info = try await client.getVersions()
            logger.debug("server has versions: \(info.versions)")
            
            //let register = try await client
        }
    }
}
