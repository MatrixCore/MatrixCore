//
//  File.swift
//
//
//  Created by Finn Behrens on 24.04.22.
//

import AnyCodable
import Foundation

public struct MatrixStateEvent: MatrixEvent {
    public static let type: String = ""

    /// The content of the event.
    @MatrixCodableStateEventType
    var content: MatrixStateEventType

    public var stateKey: String = ""

    public var eventID: String?

    public var sender: MatrixFullUserIdentifier?

    public var date: Date?

    public var unsigned: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case content
        case stateKey = "state_key"
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stateKey = try container.decode(String.self, forKey: .stateKey)
        eventID = try container.decode(String.self, forKey: .eventID)
        sender = try container.decode(MatrixFullUserIdentifier.self, forKey: .sender)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        unsigned = try container.decodeIfPresent(AnyCodable.self, forKey: .unsigned)

        let typeContainer = try decoder.container(keyedBy: MatrixStateEventTypeCodingKeys.self)
        let typeId = try typeContainer.decode(String.self, forKey: .type)

        let superEncoder = try container.superDecoder(forKey: .content)
        _content = try MatrixCodableStateEventType(from: superEncoder, typeID: typeId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stateKey, forKey: .stateKey)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(sender, forKey: .sender)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(unsigned, forKey: .unsigned)

        let contentType = Swift.type(of: content)

        var typeContainer = encoder.container(keyedBy: MatrixStateEventTypeCodingKeys.self)
        try typeContainer.encode(contentType.type, forKey: .type)

        let superEncoder = container.superEncoder(forKey: .content)
        try _content.encode(to: superEncoder)
    }
}
