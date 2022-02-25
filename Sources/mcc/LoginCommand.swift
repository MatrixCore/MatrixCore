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

struct LoginCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login to a matrix homeserver"
    )
    
    @Option(name: .long, help: "The server to login to.")
    var homeserver: String

    @Option(name: .shortAndLong, help: "The userid to use to login")
    var userID: String
    
    @Option(name: .shortAndLong, help: "Password to log in with")
    var password: String
    
    @Option(name: .shortAndLong, help: "Device id to set")
    var deviceId: String?
    
    func run() async throws {
        let logger = Logger.init()
        let client = await MatrixClient.init(homeserver: try MatrixHomeserver.init(resolve: homeserver))
        
        logger.debug("resolved url: \(client.homeserver.url)")
        
        let info = try await client.getVersions()
        logger.debug("server has versions: \(info.versions)")
        
        let login = try await client.login(username: userID, password: password, deviceId: deviceId)
        print("user id: \(login.userId ?? "")")
        print("token: \(login.accessToken ?? "")")
        print("device id: \(login.deviceId ?? "")")
    }
}
