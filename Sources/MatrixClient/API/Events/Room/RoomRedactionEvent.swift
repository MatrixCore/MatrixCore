import AnyCodable
import Foundation

public struct MatrixRedactionEvent: MatrixEvent {
    public static let type = "m.room.redaction"

    public var content: Content
    public var eventID: String?
    public var sender: MatrixFullUserIdentifier?
    public var date: Date?
    public var unsigned: AnyCodable?

    public let redacts: String?

    enum CodingKeys: String, CodingKey {
        case content
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case redacts
    }

    public struct Content: Codable {
        public let reason: String?
    }
}
