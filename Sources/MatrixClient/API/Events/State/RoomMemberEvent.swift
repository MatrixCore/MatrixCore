import AnyCodable
import Foundation

public struct MatrixMemberEvent: MatrixEvent {
    public static let type = "m.room.member"

    public var content: Content
    public var eventID: String?
    public var sender: String?
    public var date: Date?
    public var unsigned: AnyCodable?

    public let stateKey: String?

    enum CodingKeys: String, CodingKey {
        case content
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case stateKey = "state_key"
    }

    public struct Content: Codable {
        public let avatarURL: String?
        public let displayName: String?
        public let membership: MatrixMembership?
        public let isDirect: Bool?

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatar_url"
            case displayName = "displayname"
            case membership
            case isDirect = "is_direct"
        }
    }
}
