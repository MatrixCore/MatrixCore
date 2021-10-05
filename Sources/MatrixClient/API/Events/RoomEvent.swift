import Foundation
import AnyCodable

/// A protocol that all room event structs should conform to in order
/// to be decoded by the client. Don't forget to add any new structs
/// to `Client.eventTypes` for included in the JSON decoder.
public protocol MatrixEvent: Codable {
    static var type: String { get }
    
    // var content: Content { get }
    var eventID: String { get }
    var sender: String { get }
    var date: Date { get }
    var unsigned: AnyCodable? { get }
}

/// The coding keys needed to determine an event's type before decoding.
enum RoomEventTypeKeys: CodingKey {
    case type
}

enum RoomEventDecodableError: Error {
    case missingTypes
    case unableToFindType(String)
    case unableToCast(decoded: MatrixEvent?, into: String)
}

extension KeyedDecodingContainer {
    // The synthesized decoding for RoomEventArray will throw if the key is missing. This fixes that.
    func decode<T>(_ type: MatrixDecodableEvents<T>.Type, forKey key: Self.Key) throws -> MatrixDecodableEvents<T> {
        return try decodeIfPresent(type, forKey: key) ?? MatrixDecodableEvents<T>(wrappedValue: nil)
    }
}

extension CodingUserInfoKey {
    /// The key used to determing the types of `RoomEvent` that can be decoded.
    static var roomEventTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "uk.pixlwave.RoomEventTypes")!
    }
}

// TODO: encodable
@propertyWrapper
public struct MatrixDecodableEvents<Value: Collection>: Decodable where Value.Element == MatrixEvent {
    public var wrappedValue: Value?
    
    // TODO: encodable?
    private struct RoomEventWrapper<T>: Decodable {
        var wrappedEvent: T?
        
        init(from decoder: Decoder) throws {
            // these can throw as something has gone seriously wrong if the type key is missing
            let container = try decoder.container(keyedBy: RoomEventTypeKeys.self)
            let typeID = try container.decode(String.self, forKey: .type)
            
            guard let types = decoder.userInfo[.roomEventTypes] as? [MatrixEvent.Type] else {
                // the decoder must be supplied with some event types to decode
                throw RoomEventDecodableError.missingTypes
            }
            
            guard let matchingType = types.first(where: { $0.type == typeID }) else {
                // simply ignore events with no matching type as throwing would prevent access to other events
                return
            }
            
            guard let decoded = try? matchingType.init(from: decoder) else {
                assertionFailure("Failed to decode RoomEvent as \(String(describing: T.self))")
                return
            }
            
            guard let decoded = decoded as? T else {
                // something has probably gone very wrong at this stage
                throw RoomEventDecodableError.unableToCast(decoded: decoded, into: String(describing: T.self))
            }
            
            self.wrappedEvent = decoded
        }
    }
    
    
    /// An initializer that allows initialization with a wrapped value of `nil`
    /// to support arrays that may be excluded in the JSON responses.
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) {
        guard let container = try? decoder.singleValueContainer(),
              let wrappers = try? container.decode([RoomEventWrapper<Value.Element>].self)
        else { return }
        
        wrappedValue = wrappers.compactMap(\.wrappedEvent) as? Value
    }
}
