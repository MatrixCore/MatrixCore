//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import AnyCodable
import Foundation

/// This is the first event in a room and cannot be changed. It acts as the root of all other events.
///
/// # Example
/// ```json
/// {
/// "content": {
///     "creator": "@example:example.org",
///     "m.federate": true,
///     "predecessor": {
///         "event_id": "$something:example.org",
///         "room_id": "!oldroom:example.org"
///     },
///     "room_version": "1"
/// },
/// "event_id": "$143273582443PhrSn:example.org",
/// "origin_server_ts": 1432735824653,
/// "room_id": "!jEsUZKDJdhlrceRyVU:example.org",
/// "sender": "@example:example.org",
/// "state_key": "",
/// "type": "m.room.create",
/// "unsigned": {
///     "age": 1234
/// }
/// }
/// ```
public struct MatrixRoomCreateEvent: MatrixEvent {
    public static var type = "m.room.create"

    public var content: Content

    public var type: String

    public var eventID: String
    public var sender: String
    public var date: Date
    public var unsigned: AnyCodable?
}

public extension MatrixRoomCreateEvent {
    struct Content: Codable {
        /// The `user_id` of the room creator. This is set by the homeserver.
        public var creator: String

        /// Whether users on other servers can join this room. Defaults to true if key does not exist.
        public var federate: Bool?

        /// A reference to the room this room replaces, if the previous room was upgraded.
        public var predecessor: PreviousRoom?

        /// The version of the room. Defaults to "1" if the key does not exist.
        public var roomVersion: String = "1"

        // TODO: add links
        /// Optional room [type] to denote a room’s intended function outside of traditional conversation.
        ///
        /// Unspecified room types are possible using [Namespaced Identifiers].
        public var roomType: String?

        enum CodingKeys: String, CodingKey {
            case creator
            case federate = "m.federate"
            case predecessor
            case roomVersion = "room_version"
            case roomType = "type"
        }
    }
}

/// A reference to an old room.
public extension MatrixRoomCreateEvent.Content {
    struct PreviousRoom: Codable {
        /// The event ID of the last known event in the old room.
        public var eventId: String

        /// The ID of the old room.
        public var roomId: String

        enum CodingKeys: String, CodingKey {
            case eventId = "event_id"
            case roomId = "room_id"
        }
    }
}
