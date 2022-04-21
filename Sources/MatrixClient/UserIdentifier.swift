//
//  File.swift
//
//
//  Created by Finn Behrens on 24.03.22.
//

import Foundation

public protocol MatrixUserIdentifierProtocol: Equatable, Comparable {
    var localpart: String { get set }

    init?(string: String)
}

/// Users within Matrix are uniquely identified by their Matrix user ID.
///
/// The user ID is namespaced to the homeserver which allocated the account and has the form:
/// ```md
/// @localpart:domain
/// ```
///
/// The ``localpart`` of a user ID is an opaque identifier for that user. It
/// MUST NOT be empty, and MUST contain only the characters `a-z`, `0-9`, `.`, `_`, `=`, `-`, and `/`.
///
/// The ``domain`` of a user ID is the server name of the homeserver which allocated the account.
///
/// The length of a user ID, including the `@` sigil and the domain, MUST NOT exceed 255 characters.
///
/// The complete grammar for a legal user ID is:
/// ```md
/// user_id = "@" user_id_localpart ":" server_name
/// user_id_localpart = 1*user_id_char
/// user_id_char = DIGIT
/// / %x61-7A                   ; a-z
/// / "-" / "." / "=" / "_" / "/"
/// ```
///
/// ## Rational
/// A number of factors were considered when defining the allowable characters for a user ID.
///
/// Firstly, we chose to exclude characters outside the basic US-ASCII character set.
/// User IDs are primarily intended for use as an identifier at the protocol level,
/// and their use as a human-readable handle is of secondary benefit. Furthermore,
/// they are useful as a last-resort differentiator between users with similar display names.
/// Allowing the full Unicode character set would make very difficult for a human to distinguish two similar user IDs.
/// The limited character set used has the advantage that even a user unfamiliar with the Latin alphabet should be
/// able to distinguish similar user IDs manually, if somewhat laboriously.
///
/// We chose to disallow upper-case characters because we do not consider it valid to have two user IDs which differ only in case:
/// indeed it should be possible to reach `@user:matrix.org` as `@USER:matrix.org`.
/// However, user IDs are necessarily used in a number of situations which are inherently case-sensitive
/// (notably in the `state_key` of `m.room.member` events). Forbidding upper-case characters
/// (and requiring homeservers to downcase usernames when creating user IDs for new users) is a relatively
/// simple way to ensure that `@USER:matrix.org` cannot refer to a different user to  `@user:matrix.org`.
///
/// Finally, we decided to restrict the allowable punctuation to a very basic set to reduce the possibility of conflicts with
/// special characters in various situations. For example, “*” is used as a wildcard in some APIs (notably the filter API),
/// so it cannot be a legal user ID character.
///
/// The length restriction is derived from the limit on the length of the `sender` key on events; since the user ID
/// appears in every event sent by the user, it is limited to ensure that the user ID does not dominate over the actual
/// content of the events.
public struct MatrixUserIdentifier: RawRepresentable, MatrixUserIdentifierProtocol {
    public static func < (lhs: MatrixUserIdentifier, rhs: MatrixUserIdentifier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var localpart: String
    public var domain: String?

    public init?(string: String) {
        self.init(rawValue: string)
    }

    public init(locapart: String, domain: String? = nil) {
        localpart = locapart
        self.domain = domain
    }

    public init?(rawValue: String) {
        let rawValue = rawValue.lowercased()
        if rawValue.count > 255 {
            return nil
        }

        if rawValue.starts(with: "@"), !rawValue.contains(":") {
            return nil
        }

        let localpart: String
        let server: String?
        if rawValue.starts(with: "@") {
            let endLocalpart = rawValue.firstIndex(of: ":")!
            localpart = String(rawValue[rawValue.index(after: rawValue.startIndex) ..< endLocalpart])
            server = String(rawValue[rawValue.index(after: endLocalpart) ..< rawValue.endIndex])
        } else {
            localpart = rawValue
            server = nil
        }

        self.localpart = localpart
        domain = server

        if !isValid() {
            return nil
        }
    }

    func isValid() -> Bool {
        if localpart.rangeOfCharacter(from: MatrixUserIdentifier.allowedLocalCharacters.inverted) != nil {
            if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                MatrixClient.logger.info("UserID localpart contains invalid characters")
            }
            // FIXME: check for legacy character set
            return false
        }

        if let server = domain,
           server.rangeOfCharacter(from: MatrixUserIdentifier.allowedServerCharacters.inverted) != nil
        {
            if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
                MatrixClient.logger.info("UserID server contains invalid characters")
            }
            return false
        }

        if localpart.count + (domain?.count ?? 0) + 2 > 255 {
            return false
        }

        return true
    }

    // MARK: computed variables

    public var rawValue: String {
        if let server = domain {
            return "@\(localpart):\(server)"
        }
        return localpart
    }

    public var FQMXID: String? {
        if let server = domain {
            return "@\(localpart):\(server)"
        }
        return nil
    }

    // MARK: static variables

    static let allowedLocalCharacters = CharacterSet(charactersIn: "1234567890abcdefghijklmnopqrstuvwxyz-.=_/")
    static let allowedServerCharacters = CharacterSet.urlHostAllowed
}

extension MatrixUserIdentifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        let id = MatrixUserIdentifier(string: rawValue)
        if let id = id {
            self = id
        } else {
            throw MatrixError.BadJSON
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct MatrixFullUserIdentifier: RawRepresentable, MatrixUserIdentifierProtocol {
    public init(localpart: String, domain: String) {
        self.localpart = localpart
        self.domain = domain
    }

    public var localpart: String
    public var domain: String

    public init?(rawValue: MatrixUserIdentifier) {
        guard let domain = rawValue.domain else {
            return nil
        }
        self.domain = domain
        localpart = rawValue.localpart
    }

    public init?(string: String) {
        guard let rawValue = MatrixUserIdentifier(string: string)
        else {
            return nil
        }
        guard let domain = rawValue.domain else {
            return nil
        }
        self.domain = domain
        localpart = rawValue.localpart
    }

    public var rawValue: MatrixUserIdentifier {
        .init(locapart: localpart, domain: domain)
    }

    public var FQMXID: String {
        "@\(localpart):\(domain)"
    }

    public typealias RawValue = MatrixUserIdentifier

    public static func < (lhs: MatrixFullUserIdentifier, rhs: MatrixFullUserIdentifier) -> Bool {
        lhs.FQMXID < rhs.FQMXID
    }
}

extension MatrixFullUserIdentifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        let id = MatrixFullUserIdentifier(string: rawValue)
        if let id = id {
            self = id
        } else {
            throw MatrixError.BadJSON
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
