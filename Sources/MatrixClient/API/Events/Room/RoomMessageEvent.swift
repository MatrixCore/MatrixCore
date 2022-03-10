import AnyCodable
import Foundation

public struct MatrixMessageEvent: MatrixEvent {
    public static var type = "m.room.message"

    public let content: MatrixMessageContent
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
}
