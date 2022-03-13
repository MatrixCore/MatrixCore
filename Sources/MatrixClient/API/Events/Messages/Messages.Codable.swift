//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import AnyCodable
import Foundation

// MARK: - Messag types

public protocol MatrixMessageType: Codable {
    static var type: String { get }
}

enum MatrixMessageTypeCodingKeys: String, CodingKey {
    case type = "msgtype"
}

extension CodingUserInfoKey {
    static var matrixMessageTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "MatrixClient.MessageTypes")!
    }
}

/* extension [String: AnyCodable]: MatrixMessageType {
     static public var type: String = ""
 } */

@propertyWrapper
public struct MatrixCodableMessageType: Codable {
    public var wrappedValue: MatrixMessageType

    /// An initializer that allows initialization with a wrapped value of `nil`
    /// to support arrays that may be excluded in the JSON responses.
    public init(wrappedValue: MatrixMessageType) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MatrixMessageTypeCodingKeys.self)
        let typeID = try container.decode(String.self, forKey: .type)

        guard let types = decoder.userInfo[.matrixMessageTypes] as? [MatrixMessageType.Type] else {
            throw MatrixEventCodableError.missingTypes
        }

        guard let matchingType = types.first(where: { $0.type == typeID }) else {
            throw MatrixEventCodableError.missingTypes
        }

        let decoded = try matchingType.init(from: decoder)

        wrappedValue = decoded
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
        // try wrappedValue.encode(to: encoder)

        /* guard let types = encoder.userInfo[.matrixMessageTypes] as? [MatrixMessageType.Type] else {
             throw MessageTypeError.missingTypes
         }

         let matchingType = types.first(
             let new = wrappedValue as? $0.self;
             true
         })
         if let matchingType = types.first(where: { testType in (wrappedValue as? testType.Type) != nil }) {

         } */

        /* var container = encoder.container(keyedBy: MatrixMessageTypeCodingKeys.self)
         try container.encode(wrappedValue, forKey: .type) */
    }

    public enum MessageTypeError: Error {
        case missingTypes
        case unableToFindType(String)
        case unableToCast(decoded: MatrixMessageType?, into: MatrixMessageType.Type)
    }
}
