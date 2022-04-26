//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import Foundation

public protocol MatrixStateEventType: Codable {
    static var type: String { get }
}

enum MatrixStateEventTypeCodingKeys: String, CodingKey {
    case type
    case content
}

public extension CodingUserInfoKey {
    static var matrixStateEventTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "MatrixClient.StateTypes")!
    }
}

@propertyWrapper
public struct MatrixCodableStateEventType: Encodable {
    public var wrappedValue: MatrixStateEventType

    public init(wrappedValue: MatrixStateEventType) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder, typeID: String) throws {
        guard let types = decoder.userInfo[.matrixStateEventTypes] as? [MatrixStateEventType.Type] else {
            throw StateTypeError.missingTypes
        }

        guard let matchingType = types.first(where: { $0.type == typeID }) else {
            throw StateTypeError.unableToFindType(typeID)
        }

        let decoded = try matchingType.init(from: decoder)

        wrappedValue = decoded
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public enum StateTypeError: LocalizedError {
        case missingTypes
        case unableToFindType(String)
        // case unableToCast(decoded: MatrixStateEventType?, into: MatrixStateEventType.Type)

        public var errorDescription: String? {
            switch self {
            case .missingTypes:
                return NSLocalizedString("Types are missing", comment: "StateTypeError")
            case let .unableToFindType(type):
                return NSLocalizedString("Type \(type) could not be found", comment: "")
            }
        }
    }
}
