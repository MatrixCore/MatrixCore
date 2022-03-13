//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import AnyCodable
import Foundation

// TODO: Links
public struct MatrixCreateRoomRequest: Codable {
    /// Extra keys, such as `m.federate`, to be added to the content of the
    /// ``MatrixClient/ event. The server will overwrite the following keys: creator, room_version. Future versions of the specification may allow the server to overwrite other keys.
    public var creationContent: MatrixRoomCreateEvent.Content?

    /// A list of state events to set in the new room.
    ///
    /// This allows the user to override the default state events set in the new room.
    /// The expected format of the state events are an object with type, state_key and
    /// content keys set.
    ///
    /// Takes precedence over events set by preset, but gets overridden by name and topic keys.
    public var initialState: [StateEvent]?

    /// A list of user IDs to invite to the room.
    ///
    /// This will tell the server to invite everyone in the list to the newly created room.
    public var invite: [String]?

    /// A list of objects representing third party IDs to invite into the room.
    public var invite3Pid: [Invite3pid]?

    /// This flag makes the server set the is_direct flag on the m.room.member
    /// events sent to the users in invite and invite_3pid.
    ///
    /// See [Direct Messaging] for more information.
    public var isDirect: Bool?

    /// If this is included, an `m.room.name` event will be sent into the room to indicate
    /// the name of the room.
    ///
    /// See [Room Events] for more information on m.room.name.
    public var name: String?

    // TODO:
    // The power level content to override in the default power level event.
    //
    // This object is applied on top of the generated
    // `m.room.power_levels` event content prior to it being sent to the room.
    // Defaults to overriding nothing.
    // public var powerLevelContentOverride:

    /// Convenience parameter for setting various default state events based on a preset.
    ///
    /// If unspecified, the server should use the visibility to determine which preset to use.
    /// A visibility of public equates to a preset of public_chat and private visibility equates
    /// to a preset of private_chat.
    public var preset: Preset?

    /// The desired room alias **local part**.
    ///
    /// If this is included, a room alias will be created and mapped to the newly created room.
    /// The alias will belong on the same homeserver which created the room.
    /// For example, if this was set to “foo” and sent to the homeserver “example.com”
    /// the complete room alias would be #foo:example.com.
    ///
    /// The complete room alias will become the canonical alias
    /// for the room and an `m.room.canonical_alias` event will be sent into the room.
    public var roomAliasName: String?

    /// The room version to set for the room.
    ///
    /// If not provided, the homeserver is to use its configured default.
    /// If provided, the homeserver will return a 400 error with the
    /// errcode M_UNSUPPORTED_ROOM_VERSION if it does not support the room version.
    public var roomVersion: String?

    /// If this is included, an `m.room.topic` event will be sent into the room to indicate the topic for the room.
    /// See Room Events for more information on `m.room.topic`.
    public var topic: String?

    /// Visibility of the room.
    public var visibility: Visibility? = .private

    enum CodingKeys: String, CodingKey {
        case creationContent = "creation_content"
        case initialState = "initial_state"
        case invite
        case invite3Pid = "invite_3pid"
        case isDirect = "is_direct"
        case name
        // case powerLevelContentOverride = "power_level_content_override"
        case preset
        case roomAliasName = "room_alias_name"
        case roomVersion = "room_version"
        case topic
    }
}

public extension MatrixCreateRoomRequest {
    enum Preset: String, RawRepresentable, Codable {
        case privateChat = "private_chat"
        case publicChat = "public_chat"
        case trustedPrivateChat = "trusted_private_chat"
    }

    struct Invite3pid: Codable {
        /// The invitee’s third party identifier.
        public var address: String

        /// An access token previously registered with the identity server.
        /// Servers can treat this as optional to distinguish between r0.5-compatible
        /// clients and this specification version.
        public var idAccessToken: String

        /// The hostname+port of the identity server which should be used for third party
        /// identifier lookups.
        public var idServer: String

        /// The kind of address being passed in the address field, for example email.
        public var medium: String
    }

    struct StateEvent: Codable {
        /// The content of the event.
        public var content: [String: AnyCodable]

        /// The state_key of the state event. Defaults to an empty string.
        public var stateKey: String?

        /// The type of event to send.
        public var type: String

        enum CodingKeys: String, CodingKey {
            case content
            case stateKey = "state_key"
            case type
        }
    }

    enum Visibility: String, RawRepresentable, Codable {
        /// A public visibility indicates that the room will be shown in the published room list.
        case `public`
        /// A private visibility will hide the room from the published room list.
        case `private`
    }
}

extension MatrixCreateRoomRequest: MatrixRequest {
    public typealias Response = MatrixCreateRoom

    public typealias URLParameters = ()

    public func components(for homeserver: MatrixHomeserver, with _: ()) throws -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/v3/createRoom"

        return components
    }

    public static var httpMethod: HttpMethod {
        .POST
    }

    public static var requiresAuth: Bool {
        true
    }
}

public struct MatrixCreateRoom: MatrixResponse {
    /// The created room’s ID.
    public var roomId: String

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
    }
}
