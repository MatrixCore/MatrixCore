//
//  File.swift
//  
//
//  Created by Finn Behrens on 05.02.22.
//

import Foundation
import ArgumentParser
import MatrixClient
import os

extension Mcc.Auth {
    struct Login: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "login",
            abstract: "Login to a matrix homeserver"
        )
        
        @OptionGroup var options: Options
        
        @Option(name: .shortAndLong, help: "Password to log in with")
        var password: String
        
        @Option(name: .shortAndLong, help: "Device id to set")
        var deviceId: String?
        
        func run() async throws {
            let logger = Logger.init()
            let client = await MatrixClient(homeserver: try MatrixHomeserver(resolve: options.homeserver))
            
            logger.debug("resolved url: \(client.homeserver.url)")
            
            let info = try await client.getVersions()
            logger.debug("server has versions: \(info.versions)")
            
            if !(try await client.supportsPasswordAuth()) {
                logger.warning("Server does not support password authentication.")
                throw MatrixError.Forbidden
            }
            
            let login = try await client.login(username: options.userID, password: password, deviceId: deviceId)
            print("user id: \(login.userId ?? "")")
            print("token: \(login.accessToken ?? "")")
            print("device id: \(login.deviceId ?? "")")
        }
    }
}
