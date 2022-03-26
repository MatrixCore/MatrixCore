import AnyCodable
import Foundation

/// A protocol that all room event structs should conform to in order
/// to be decoded by the client. Don't forget to add any new structs
/// to `Client.eventTypes` for included in the JSON decoder.
public protocol MatrixEvent: Codable {
    static var type: String { get }

    var eventID: String? { get }
    var sender: String? { get }
    var date: Date? { get }
    var unsigned: AnyCodable? { get }
}

/// The coding keys needed to determine an event's type before decoding.
enum MatrixEventTypeKeys: CodingKey {
    case type
}

enum MatrixEventCodableError: Error {
    case missingTypes
    case unableToFindType(String)
    case unableToCast(decoded: MatrixEvent?, into: String)
}

extension KeyedDecodingContainer {
    // The synthesized decoding for MatrixCodableEvents will throw if the key is missing. This fixes that.
    func decode<T>(_ type: MatrixCodableEvents<T>.Type, forKey key: Self.Key) throws -> MatrixCodableEvents<T> {
        try decodeIfPresent(type, forKey: key) ?? MatrixCodableEvents<T>(wrappedValue: nil)
    }
}

extension CodingUserInfoKey {
    /// The key used to determine the types of `MatrixEvent` that can be decoded.
    static var matrixEventTypes: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "MatrixClient.EventTypes")!
    }
}

// TODO: encodable
@propertyWrapper
public struct MatrixCodableEvents<Value: Collection>: Codable where Value.Element == MatrixEvent {
    public var wrappedValue: Value?

    // TODO: encodable?
    private struct EventWrapper<T>: Codable {
        var wrappedEvent: T?

        init(from decoder: Decoder) throws {
            // these can throw as something has gone seriously wrong if the type key is missing
            let container = try decoder.container(keyedBy: MatrixEventTypeKeys.self)
            let typeID = try container.decode(String.self, forKey: .type)

            guard let types = decoder.userInfo[.matrixEventTypes] as? [MatrixEvent.Type] else {
                // the decoder must be supplied with some event types to decode
                throw MatrixEventCodableError.missingTypes
            }

            guard let matchingType = types.first(where: { $0.type == typeID }) else {
                // simply ignore events with no matching type as throwing would prevent access to other events
                return
            }

            guard let decoded = try? matchingType.init(from: decoder) else {
                assertionFailure("Failed to decode MatrixEvent as \(String(describing: T.self))")
                return
            }

            guard let decoded = decoded as? T else {
                // something has probably gone very wrong at this stage
                throw MatrixEventCodableError.unableToCast(decoded: decoded, into: String(describing: T.self))
            }

            wrappedEvent = decoded
        }

        func encode(to encoder: Encoder) throws {
            let wrappedEvent = wrappedEvent as! Codable
            let contentType = type(of: wrappedEvent) as! MatrixEvent.Type

            try wrappedEvent.encode(to: encoder)

            var container = encoder.container(keyedBy: MatrixEventTypeKeys.self)
            try container.encode(contentType.type, forKey: .type)
        }
    }

    /// An initializer that allows initialization with a wrapped value of `nil`
    /// to support arrays that may be excluded in the JSON responses.
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.singleValueContainer(),
              let wrappers = try? container.decode([EventWrapper<Value.Element>].self)
        else { return }

        wrappedValue = wrappers.compactMap(\.wrappedEvent) as? Value
    }

    public func encode(to encoder: Encoder) throws {
        let wrappedValue = wrappedValue as! Codable

        try wrappedValue.encode(to: encoder)
    }
}
