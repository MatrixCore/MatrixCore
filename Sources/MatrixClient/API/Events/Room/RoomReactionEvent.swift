import AnyCodable
import Foundation

public struct MatrixReactionEvent: MatrixEvent {
    public static var type = "m.reaction"

    public let content: Content
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
    public let unsigned: AnyCodable?

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
