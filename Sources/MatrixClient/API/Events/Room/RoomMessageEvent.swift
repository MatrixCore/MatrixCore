import AnyCodable
import Foundation

public struct MatrixMessageEvent: MatrixEvent {
    public static let type = "m.room.message"

    @MatrixCodableMessageType
    public var content: MatrixMessageType
    public var eventID: String?
    public var sender: String?
    public var date: Date?
    public var unsigned: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case content
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
    }
}
