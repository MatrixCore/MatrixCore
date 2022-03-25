import AnyCodable
import Foundation

public struct MatrixReactionEvent: MatrixEvent {
    public static let type = "m.reaction"

    public var content: Content
    public var type: String?
    public var eventID: String?
    public var sender: String?
    public var date: Date?
    public var unsigned: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
    }

    public struct Content: Codable {
        public let relationship: MatrixRelationship?

        enum CodingKeys: String, CodingKey {
            case relationship = "m.relates_to"
        }
    }
}
