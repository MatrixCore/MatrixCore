import Foundation

public enum MatrixMembership: String, Codable {
    case invite, join, knock, leave, ban, unknown

    // implement a custom decoder that will decode as unknown if
    // the string received can't be decoded as one of the cases
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = MatrixMembership(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
    }
}
