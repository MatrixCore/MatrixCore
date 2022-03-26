import AnyCodable
import Foundation

public struct MatrixNameEvent: MatrixEvent {
    public static let type = "m.room.name"

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
        public let name: String?
    }
}
