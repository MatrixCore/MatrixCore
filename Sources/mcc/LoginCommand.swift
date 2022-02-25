//
//  File.swift
//  
//
//  Created by Finn Behrens on 05.02.22.
//

import Foundation
import ArgumentParser
import MatrixClient

struct LoginCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login to a matrix homeserver"
    )
    
    @Option(name: .long, help: "The server to login to.")
    var homeserver: String

    @Option(name: .shortAndLong, help: "The userid to use to login")
    var userID: String
    
    func run() async throws {
        let client = await MatrixClient.init(homeserver: try MatrixHomeserver.init(resolve: homeserver))
        
        print("resolved url: \(client.homeserver)")
    }
}
