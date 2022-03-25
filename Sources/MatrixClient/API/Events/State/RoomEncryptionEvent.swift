import AnyCodable
import Foundation

public struct MatrixEncryptionEvent: MatrixEvent {
    public static let type = "m.room.encryption"

    public var content: Content
    public var eventID: String?
    public var sender: String?
    public var date: Date?
    public var unsigned: AnyCodable?

    public var stateKey: String?

    enum CodingKeys: String, CodingKey {
        case content
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case stateKey = "state_key"
    }

    public struct Content: Codable {}
}
