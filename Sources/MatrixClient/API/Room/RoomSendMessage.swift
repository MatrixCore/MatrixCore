//
//  File.swift
//
//
//  Created by Finn Behrens on 25.03.22.
//

import Foundation

public struct MatrixRoomSendEventRequest {
    public var body: MatrixEvent

    public var roomID: String
}

extension MatrixRoomSendEventRequest: MatrixRequest {
    public typealias Response = MatrixRoomSendEvent

    public func components(for homeserver: MatrixHomeserver, with txID: Int) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/rooms/\(roomID)/send/\(type(of: body).type)/\(txID)")
    }

    public static var httpMethod: HttpMethod {
        .PUT
    }

    public static var requiresAuth: Bool {
        true
    }
}

extension MatrixRoomSendEventRequest: Codable {
    public init(from _: Decoder) throws {
        fatalError("todo")
    }

    public func encode(to encoder: Encoder) throws {
        try body.encode(to: encoder)
    }
}

public struct MatrixRoomSendEvent: MatrixResponse {
    public var eventID: String

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}
