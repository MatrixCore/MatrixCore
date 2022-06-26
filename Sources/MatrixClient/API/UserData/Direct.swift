//
//  File.swift
//
//
//  Created by Finn Behrens on 26.03.22.
//

import Foundation

public struct MatrixDirectAccountData: MatrixAccountData {
    public static var type: String = "m.direct"

    public var users: [String: [String]] = [:]
}

extension MatrixDirectAccountData: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MatrixDynamicCodingKeys.self)

        for key in container.allKeys {
            let decoded = try container.decode([String].self, forKey: key)
            users[key.stringValue] = decoded
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MatrixDynamicCodingKeys.self)
        for (name, value) in users {
            try container.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}
