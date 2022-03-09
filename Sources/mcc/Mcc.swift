//
// Created by Finn Behrens on 05.02.22.
//

import ArgumentParser
import Foundation

@main
struct Mcc: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "mcc",
        abstract: "MatrixClient tests",
        version: "0.1.0",
        subcommands: [
            Auth.self,
        ]
    )
}
