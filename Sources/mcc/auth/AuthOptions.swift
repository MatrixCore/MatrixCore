//
//  File.swift
//
//
//  Created by Finn Behrens on 02.03.22.
//

import ArgumentParser
import Foundation

extension Mcc.Auth {
    struct Options: ParsableArguments {
        @Option(name: .long, help: "The homeserver to use.")
        var homeserver: String

        @Option(name: .shortAndLong, help: "The userid to use.")
        var userID: String
    }
}
