//
//  File.swift
//
//
//  Created by Finn Behrens on 24.04.22.
//

import Foundation

/// This event is used to inform the room about which alias should be considered the canonical one, and which other aliases point to the room.
///
/// This could be for display purposes or as suggestion to users which alias to use to advertise and access the room.
public struct MatrixRoomCanonicalAliasEvent: MatrixStateEventType {
    public static let type = "m.room.canonical_alias"

    /// The canonical alias for the room.
    ///
    /// If not present, null, or empty the room should be considered to have no canonical alias.
    public var alias: String?

    /// Alternative aliases the room advertises.
    ///
    /// This list can have aliases despite the alias field being null, empty, or otherwise not present.
    public var altAliases: [String]?

    enum CodingKeys: String, CodingKey {
        case alias
        case altAliases = "alt_aliases"
    }
}

/// This is the first event in a room and cannot be changed. It acts as the root of all other events.
public struct MatrixRoomCreateEvent: MatrixStateEventType {
    public init(
        creator: MatrixFullUserIdentifier,
        federate: Bool? = nil,
        predecessor: MatrixRoomCreateEvent.PreviousRoom? = nil,
        roomVersion: String? = nil,
        roomType: RoomType? = nil
    ) {
        self.creator = creator
        self.federate = federate
        self.predecessor = predecessor
        self.roomVersion = roomVersion
        self.roomType = roomType
    }

    public static let type = "m.room.create"

    /// The ``MatrixFullUserIdentifier`` of the room creator.
    ///
    /// This is set by the homeserver
    public var creator: MatrixFullUserIdentifier

    /// Whether users on other servers can join this room.
    ///
    /// Defaults to true if key does not exist.
    public var federate: Bool?

    /// A reference to the room this room replaces, if the previous room was upgraded.
    public var predecessor: PreviousRoom?

    /// The version of the room. Defaults to "1" if the key does not exist.
    public var roomVersion: String?

    /// Optional room type to denote a room’s intended function outside of traditional conversation.
    ///
    /// Unspecified room types are possible using Namespaced Identifiers.
    public var roomType: RoomType?

    public struct PreviousRoom: Codable, Equatable, Hashable {
        /// The event ID of the last known event in the old room.
        public var eventID: String

        /// The ID of the old room.
        public var roomID: String

        enum CodingKeys: String, CodingKey {
            case eventID = "event_id"
            case roomID = "room_id"
        }
    }

    enum CodingKeys: String, CodingKey {
        case creator
        case federate = "m.federate"
        case predecessor
        case roomVersion = "room_version"
        case roomType = "type"
    }

    public struct RoomType: RawRepresentable, Codable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init?(rawValue: String){
            self.rawValue = rawValue
        }

        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)!
        }
    }
}

public struct MatrixRoomJoinRulesEvent: MatrixStateEventType {
    public static let type = "m.room.join_rules"

    /// For restricted rooms, the conditions the user will be tested against.
    ///
    /// The user needs only to satisfy one of the conditions to join the restricted room.
    /// If the user fails to meet any condition, or the condition is unable to be confirmed as satisfied,
    /// then the user requires an invite to join the room.
    /// Improper or no allow conditions on a restricted join rule imply the room is effectively invite-only (no conditions can be satisfied).
    public var allow: [AllowCondition]?

    /// The type of rules used for users wishing to join this room.
    public var joinRule: JoinRule

    public struct AllowCondition: Codable {
        /// The room ID to check the user’s membership against.
        ///
        /// If the user is joined to this room, they satisfy the condition and thus are permitted to join the restricted room.
        /// Required if type is ``ConditionType.roomMembership``.
        public var roomId: String?

        /// The type of condition
        public var type: ConditionType

        public enum ConditionType: String, Codable {
            case roomMembership = "m.room_membership"
        }
    }

    public enum JoinRule: String, Codable {
        /// Anyone can join the room without any prior action.
        case `public`
        /// A user must first receive an invite from someone already in the room in order to join.
        case invite
        /// A user can request an invite to the room.
        ///
        /// They can be allowed (invited) or denied (kicked/banned) access. Otherwise, users need to be invited in.
        /// Only available in rooms which support knocking.
        case knock
        /// Reserved without implementation. No significant meaning.
        case `private`
        /// Anyone able to satisfy at least one of the allow conditions is able to join the room without prior action.
        ///
        /// Otherwise, an invite is required. Only available in rooms which support the join rule.
        case restricted
    }

    enum CodingKeys: String, CodingKey {
        case allow
        case joinRule = "join_rule"
    }
}

/// Adjusts the membership state for a user in a room.
///
/// It is preferable to use the membership APIs (`/rooms/<room id>/invite` etc) when performing membership actions
/// rather than adjusting the state directly as there are a restricted set of valid transformations.
/// For example, user A cannot force user B to join a room, and trying to force this state change directly will fail.
///
/// The following membership states are specified:
///
/// `invite` - The user has been invited to join a room, but has not yet joined it. They may not participate in the room until they join.
///
/// `join` - The user has joined the room (possibly after accepting an invite), and may participate in it.
///
/// `leave` - The user was once joined to the room, but has since left (possibly by choice, or possibly by being kicked).
///
/// `ban` - The user has been banned from the room, and is no longer allowed to join it until they are un-banned from the room (by having their membership state set to a value other than ban).
////
/// `knock` - The user has knocked on the room, requesting permission to participate. They may not participate in the room until they join.
///
/// The third_party_invite property will be set if this invite is an invite event and is the successor of an m.room.third_party_invite event, and absent otherwise.
///
///
/// This event may also include an `invite_room_state` key inside the event’s unsigned data. If present,
/// this contains an array of stripped state events to assist the receiver in identifying the room.
///
/// The user for which a membership applies is represented by the `state_key`.
/// Under some conditions, the `sender` and `state_key` may not match - this may be interpreted as the sender
/// affecting the membership state of the `state_key` user.
///
/// The membership for a given user can change over time.
/// Previous membership can be retrieved from the `prev_content` object on an event.
/// If not present, the user’s previous membership must be assumed as leave.
public struct MatrixRoomMemberEvent: MatrixStateEventType {
    public static let type = "m.room.member"

    /// The avatar URL for this user, if any.
    public var avatarUrl: String?

    /// The display name for this user, if any.
    public var displayname: String?

    /// Flag indicating if the room containing this event was created with the intention of being a direct chat.
    public var isDirect: Bool?

    /// Usually found on join events, this field is used to denote which homeserver (through representation of a user with
    /// sufficient power level) authorised the user’s join. More information about this field can be found in the Restricted Rooms
    /// Specification.
    ///
    /// Client and server implementations should be aware of the signing implications of including this field in further events:
    ///   in particular, the event must be signed by the server which owns the user ID in the field.
    ///   When copying the membership event’s content (for profile updates and similar) it is therefore encouraged to
    ///   exclude this field in the copy, as otherwise the event might fail event authorization.
    public var joinAuthorizedViaUsersServer: String?

    /// The membership state of the user.
    public var membership: Membership

    /// Optional user-supplied text for why their membership has changed.
    ///
    /// For kicks and bans, this is typically the reason for the kick or ban.
    /// For other membership changes, this is a way for the user to communicate their intent without having to send a
    /// message to the room, such as in a case where Bob rejects an invite from Alice about an upcoming concert,
    /// but can’t make it that day.
    ///
    /// Clients are not recommended to show this reason to users when receiving an invite due to the potential for spam and abuse.
    /// Hiding the reason behind a button or other component is recommended.
    public var reason: String?

    public var thirdPartyInvite: Invite?

    public enum Membership: String, Codable {
        case invite, join, knock, leave, ban
    }

    public struct Invite: Codable {
        /// A name which can be displayed to represent the user instead of their third party identifier
        public var displayName: String

        // /// A block of content which has been signed, which servers can use to verify the event. Clients should ignore this.
        // public var signed: Signed

        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
        }
    }

    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case displayname
        case isDirect = "is_direct"
        case joinAuthorizedViaUsersServer = "join_authorised_via_users_server"
        case membership
        case reason
        case thirdPartyInvite = "third_party_invite"
    }
}

/// This event specifies the minimum level a user must have in order to perform a certain action.
/// It also specifies the levels of each user in the room.
///
/// If a `user_id` is in the users list, then that `user_id` has the associated power level.
/// Otherwise they have the default level `users_default`. If `users_default` is not supplied, it is assumed to be 0.
/// If the room contains no ``MatrixRoomPowerLevelsEvent`` event, the room’s creator has a power level of 100,
/// and all other users have a power level of 0.
///
/// The level required to send a certain event is governed by events, `state_default` and `events_default`.
/// If an event type is specified in events, then the user must have at least the level specified in order to send that event.
/// If the event type is not supplied, it defaults to events_default for Message Events and state_default for State Events.
///
/// If there is no `state_default` in the ``MatrixRoomPowerLevelsEvent`` event, the `state_default` is 50.
/// If there is no `events_default` in the ``MatrixRoomPowerLevelsEvent`` event, the `events_default` is 0. If the room contains no ``MatrixRoomPowerLevelsEvent`` event, both the `state_default` and `events_default` are 0.
///
/// The power level required to invite a user to the room, kick a user from the room, ban a user from the room, or redact an event sent
/// by another user, is defined by invite, kick, ban, and redact, respectively. Each of these levels defaults to 50 if they are not specified
/// in the ``MatrixRoomPowerLevelsEvent`` event, or if the room contains no ``MatrixRoomPowerLevelsEvent`` event.
///
///
/// ### Note
///
/// As noted above, in the absence of an ``MatrixRoomPowerLevelsEvent`` event, the `state_default` is 0, and all users
/// are considered to have power level 0. That means that any member of the room can send an
/// ``MatrixRoomPowerLevelsEvent`` event, changing the permissions in the room.
///
/// Server implementations should therefore ensure that each room has an ``MatrixRoomPowerLevelsEvent`` event as soon as
/// it is created. See also the documentation of the /createRoom API.
public struct MatrixRoomPowerLevelsEvent: MatrixStateEventType {
    public static let type = "m.room.power_levels"

    /// The level required to ban a user. Defaults to 50 if unspecified.
    public var ban: Int? = 50

    /// The level required to send specific event types. This is a mapping from event type to power level required.
    public var events: [String: Int]?

    /// The default level required to send message events. Can be overridden by the events key. Defaults to 0 if unspecified.
    public var eventsDefault: Int? = 0

    /// The level required to invite a user. Defaults to 50 if unspecified.
    public var invite: Int? = 50

    /// The level required to kick a user. Defaults to 50 if unspecified.
    public var kick: Int? = 50

    /// The power level requirements for specific notification types. This is a mapping from key to power level for that notifications key.
    public var notifications: Notifications?

    /// The level required to redact an event sent by another user. Defaults to 50 if unspecified.
    public var redact: Int? = 50

    /// The default level required to send state events. Can be overridden by the events key. Defaults to 50 if unspecified.
    public var stateDefault: Int? = 50

    /// The power levels for specific users. This is a mapping from user_id to power level for that user.
    public var users: [String: Int]?

    /// The default power level for every user in the room, unless their user_id is mentioned in the users key.
    /// Defaults to 0 if unspecified.
    public var usersDefault: Int? = 0

    public struct Notifications: Codable {
        /// The level required to trigger an @room notification. Defaults to 50 if unspecified.
        public var room: Int? = 50
    }

    enum CodingKeys: String, CodingKey {
        case ban, events
        case eventsDefault = "events_default"
        case invite, kick
        case notifications
        case redact
        case stateDefault = "state_default"
        case users
        case usersDefault = "user_default"
    }
}

/// A room has an opaque room ID which is not human-friendly to read.
/// A room alias is human-friendly, but not all rooms have room aliases.
/// The room name is a human-friendly string designed to be displayed to the end-user.
/// The room name is not unique, as multiple rooms can have the same room name set.
///
/// A room with an ``MatrixRoomNameEvent`` event with an absent, null, or empty ``name`` field should be treated the same as
/// a room with no ``MatrixRoomNameEvent`` event.
///
/// An event of this type is automatically created when creating a room using /createRoom with the name key.
public struct MatrixRoomNameEvent: MatrixStateEventType {
    public static let type = "m.room.name"

    /// The name of the room. This MUST NOT exceed 255 bytes.
    public var name: String
}

/// A topic is a short message detailing what is currently being discussed in the room.
/// It can also be used as a way to display extra information about the room, which may not be suitable for the room name.
/// The room topic can also be set when creating a room using /createRoom with the topic key.
public struct MatrixRoomTopicEvent: MatrixStateEventType {
    public static let type = "m.room.topic"

    /// The topic text.
    public var topic: String
}

/// A picture that is associated with the room. This can be displayed alongside the room information.
public struct MatrixRoomAvatarEvent: MatrixStateEventType {
    public static let type = "m.room.avatar"

    /// Metadata about the image referred to in ``url``.
    public var info: MatrixMessageImage.ImageInfo

    /// The URL to the image.
    public var url: String
}

/// This event is used to “pin” particular events in a room for other participants to review later.
///
/// The order of the pinned events is guaranteed and based upon the order supplied in the event.
/// Clients should be aware that the current user may not be able to see some of the events pinned due to visibility settings in the room.
/// Clients are responsible for determining if a particular event in the pinned list is displayable, and have the option to not display it if it
/// cannot be pinned in the client.
public struct MatrixRoomPinnedEvents: MatrixStateEventType {
    public static let type: String = "m.room.pinned_events"

    /// An ordered list of event IDs to pin.
    public var pinned: [String]
}

/// Defines how messages sent in this room should be encrypted.
public struct MatrixRoomEncryptionEvent: MatrixStateEventType {
    public static let type: String = "m.room.encryption"

    /// The encryption algorithm to be used to encrypt messages sent in this room.
    public var algorithm: Algorithm

    /// How long the session should be used before changing it.
    /// 604800000 (a week) is the recommended default.
    public var rotationPeriodMS: Int?

    /// How many messages should be sent before changing the session. 100 is the recommended default.
    public var RotationPeriodMsgs: Int?

    public enum Algorithm: String, Codable {
        case megolmV1AESSHA1 = "m.megolm.v1.aes-sha2"
    }

    enum CodingKeys: String, CodingKey {
        case algorithm
        case rotationPeriodMS = "rotation_period_ms"
        case RotationPeriodMsgs = "rotation_period_msgs"
    }
}

///
///
/// # Removing
///
/// When removing a bridge, you simply need to send a new state event with the same `state_key` with a `content` of `{}`.
/// This is because matrix does not yet have a mechanism to remove a state event in it's entireity.
public struct MatrixRoomBridgeEvent: MatrixStateEventType {
    public static let type: String = "m.bridge"
    public static let unstableType: String = "uk.half-shot.bridge"

    /// Should be the MXID of the bridge bot.
    ///
    /// It is important to note that `sender` should not be presumed to be the bridge bot.
    /// This is because room upgrades, other bridges or admins could also set the state in the room on behalf of the bridge bot.
    public var bridgebot: MatrixFullUserIdentifier?

    /// The name of the user which provisioned the bridge.
    ///
    /// In the case of alias based bridges, where the creator is not known it should be omitted.
    public var creator: MatrixFullUserIdentifier?

    /// Describes the protocol that is being bridged.
    ///
    /// For example, it may be `"IRC"`, `"Slack"`, or `"Discord"`.
    /// This field does not describe the low level protocol the bridge is using to access the network,
    /// but a common user recongnisable name.
    public var `protocol`: External?

    /// Should be information about the specific network the bridge is connected to.
    ///
    /// It's important to make the distinction here that this does NOT describe the protocol name, but the specific network the user is on.
    /// For protocols that do not have the concept of a network, this field may be omitted.
    public var network: External?

    /// Should be information about the specific channel the room is connected to.
    public var channel: External?

    public struct External: Codable {
        /// Case-insensitive and should be lowercase.
        ///
        /// Uppercase characters should be escaped (e.g. using QP encoding or similar).The purpose of the id field is not to be human
        /// readable but just for comparing within the same bridge type, hence no encoding standard will be enforced in this proposal.
        public var id: String
        public var displayname: String?
        public var avatarUrl: String?
        public var externalUrl: String?

        enum CodingKeys: String, CodingKey {
            case id
            case displayname
            case avatarUrl = "avatar_url"
            case externalUrl = "external_url"
        }
    }

    /// Test if this state event is a redaction of an old bridge information.
    public var isEmpty: Bool {
        bridgebot == nil && `protocol` == nil && channel == nil
    }
}
