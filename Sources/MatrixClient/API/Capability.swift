//
//  File.swift
//
//
//  Created by Finn Behrens on 11.03.22.
//

import AnyCodable
import Foundation

public struct MatrixCapabilitiesRequest: MatrixRequest {
    public typealias Response = MatrixCapabilities

    public typealias URLParameters = ()

    public func components(for homeserver: MatrixHomeserver, with _: URLParameters) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/v3/capabilities"
        return components
    }

    public static var httpMethod = HttpMethod.GET

    public static var requiresAuth = true
}

public struct MatrixCapabilities: MatrixResponse {
    public init(capabilities: MatrixCapabilities.Capabilities = Capabilities()) {
        self.capabilities = capabilities
    }

    /// The custom capabilities the server supports, using the Java package naming convention.
    public var capabilities: Capabilities
}

public extension MatrixCapabilities {
    struct Capabilities: Codable {
        public init(
            changePassword: MatrixCapabilities.Capabilities.BooleanCapability? = nil,
            roomVersions: MatrixCapabilities.Capabilities.RoomVersionsCapability? = nil,
            extraInfo: [String: AnyCodable] = [:]
        ) {
            self.changePassword = changePassword
            self.roomVersions = roomVersions
            self.extraInfo = extraInfo
        }

        /// Capability to indicate if the user can change their password.
        ///
        /// This capability has a single flag, enabled, which indicates whether or not the user can use
        /// the /account/password API to change their password. If not present, the client should
        /// assume that password changes are possible via the API. When present, clients SHOULD
        /// respect the capability’s enabled flag and indicate to the user if they are unable to change their password.
        ///
        /// # Example
        /// ```swift
        /// let changePasswordCapability = BooleanCapability(
        ///     enabled: false
        /// )
        /// ```
        public var changePassword: BooleanCapability?

        /// Capability to indicate if the user can change their display name.
        ///
        /// This capability has a single flag, enabled, to denote whether the user is able to change their own display
        /// name via profile endpoints. Cases for disabling might include users mapped from external identity/directory
        /// services, such as LDAP.
        ///
        /// Note that this is well paired with the
        /// ``MatrixClient/MatrixCapabilities/Capabilities-swift.struct/setAvatarUrl`` capability.
        ///
        /// # Example
        /// ```swift
        /// let setDisplayNameCapability = BooleanCapability(
        ///     enabled: false
        /// )
        /// ```
        public var setDisplayName: BooleanCapability?

        /// Capability to indicate if the user can change their avatar.
        ///
        /// This capability has a single flag, enabled, to denote whether the user is able to change their own avatar via profile
        /// endpoints. Cases for disabling might include users mapped from external identity/directory services, such as LDAP.
        ///
        /// Note that this is well paired with the
        /// ``MatrixClient/MatrixCapabilities/Capabilities-swift.struct/setDisplayName`` capability.
        ///
        /// # Example
        /// ```swift
        /// let setAvatarUrlCapability = BooleanCapability(
        ///     enabled: false
        /// )
        /// ```
        public var setAvatarUrl: BooleanCapability?

        // TODO: Change `Admin Contact Information` to link to struct implementing it.
        /// Capability to indicate if the user can change the 3PID informations.
        ///
        /// This capability has a single flag, enabled, to denote whether the user is able to add, remove, or change
        /// 3PID associations on their account. Note that this only affects a user’s ability to use the
        /// `Admin Contact Information` API, not endpoints exposed by an Identity Service.
        /// Cases for disabling might include users mapped from external identity/directory services, such as LDAP.
        public var change3Pid: BooleanCapability?

        /// The room versions the server supports.
        public var roomVersions: RoomVersionsCapability?

        public var extraInfo: [String: AnyCodable] = [:]
    }
}

public extension MatrixCapabilities.Capabilities {
    struct BooleanCapability: Codable {
        public init(enabled: Bool = true) {
            self.enabled = enabled
        }

        /// True if the user can change their password, false otherwise.
        public var enabled: Bool = true
    }

    /// The room versions the server supports.
    ///
    /// This capability describes the default and available room versions a server supports,
    /// and at what level of stability. Clients should make use of this capability to determine
    /// if users need to be encouraged to upgrade their rooms.
    ///
    /// This capability mirrors the same restrictions of
    /// [room versions](https://spec.matrix.org/v1.1/rooms) to describe which versions are
    /// stable and unstable. Clients should assume that the default version is stable.
    /// Any version not explicitly labelled as stable in the available versions is to be
    /// treated as unstable. For example, a version listed as future-stable should be treated as unstable.
    ///
    /// The default version is the version the server is using to create new rooms. Clients
    /// should encourage users with sufficient permissions in a room to upgrade their room
    /// to the default version when the room is using an unstable version.
    ///
    /// When this capability is not listed, clients should use `"1"` as
    /// the default and only stable available room version.
    ///
    /// # Example
    /// ```swift
    /// let roomVersionCapability = RoomVersionsCapability(
    ///   available: [
    ///     "1": .stable,
    ///     "2": .stable,
    ///     "3": .unstable,
    ///     "custom-version": .unstable,
    ///   ],
    ///   defaultVersion: "1"
    /// )
    /// ```
    struct RoomVersionsCapability: Codable {
        public init(
            available: [String: MatrixCapabilities.Capabilities.RoomVersionsCapability.RoomVersionStability],
            defaultVersion: String
        ) {
            self.available = available
            self.defaultVersion = defaultVersion
        }

        /// A detailed description of the room versions the server supports.
        public var available: [String: RoomVersionStability]

        /// The default room version the server is using for new rooms.
        public var defaultVersion: String

        public func isVersionAvailable(_ version: String) -> Bool {
            available.keys.contains(version)
        }

        public func isVersionStable(_ version: String) -> Bool {
            available[version].map { $0 == .stable } ?? false
        }

        enum CodingKeys: String, CodingKey {
            case available
            case defaultVersion = "default"
        }
    }
}

extension MatrixCapabilities.Capabilities.BooleanCapability: ExpressibleByBooleanLiteral, RawRepresentable {
    public init(booleanLiteral value: BooleanLiteralType) {
        enabled = value
    }

    public init(rawValue value: RawValue) {
        enabled = value
    }

    public typealias RawValue = Bool

    public var rawValue: RawValue {
        enabled
    }
}

public extension MatrixCapabilities.Capabilities.RoomVersionsCapability {
    struct RoomVersionStability: RawRepresentable, Codable {
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init?(rawValue: String) {
            self.rawValue = rawValue
        }

        public typealias RawValue = String

        public var rawValue: RawValue

        public static let stable: RoomVersionStability = "stable"
        public static let unstable: RoomVersionStability = "unstable"
    }
}

extension MatrixCapabilities.Capabilities.RoomVersionsCapability.RoomVersionStability: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

// MARK: - functions

public extension MatrixCapabilities.Capabilities {
    /// Capability to indicate if the user can change their password.
    ///
    /// Accessor for ``changePassword``.
    var canChangePassword: Bool {
        get {
            changePassword?.enabled ?? true
        }
        set {
            if var changePassword = self.changePassword {
                changePassword.enabled = newValue
                self.changePassword = changePassword
                return
            }
            changePassword = .init(enabled: newValue)
        }
    }


    /// Capability to indicate if the user can change their display name.
    ///
    /// Accessor for ``setDisplayName``.
    var canSetDisplayName: Bool {
        get {
            setDisplayName?.enabled ?? true
        }
        set {
            setDisplayName = .init(enabled: newValue)
        }
    }

    /// Capability to indicate if the user can change their avatar.
    ///
    /// Accessor for ``setAvatarUrl``.
    var canSetAvatarUrl: Bool {
        get {
            setAvatarUrl?.enabled ?? true
        }
        set {
            setAvatarUrl = .init(enabled: true)
        }
    }


    /// Capability to indicate if the user can change the 3PID informations.
    ///
    /// Accessor for ``change3Pid``.
    var canChange3Pid: Bool {
        get {
            change3Pid?.enabled ?? true
        }
        set {
            change3Pid = .init(enabled: true)
        }
    }

    /// Default room version.
    var defaultRoomVersion: String {
        roomVersions?.defaultVersion ?? "1"
    }
}

public extension MatrixCapabilities {
    /// Capability to indicate if the user can change their password.
    var canChangePassword: Bool {
        get {
            capabilities.canChangePassword
        }
        set {
            capabilities.canChangePassword = newValue
        }
    }

    /// Default room version.
    var defaultRoomVersion: String {
        capabilities.defaultRoomVersion
    }

    var roomVersions: Capabilities.RoomVersionsCapability? {
        capabilities.roomVersions
    }
}

// MARK: - Codable

extension MatrixCapabilities.Capabilities {
    enum KnownCodingKeys: String, CodingKey, CaseIterable {
        case changePassword = "m.change_password"
        case roomVersions = "m.room_versions"
        case setDisplayName = "m.set_displayname"
        case setAvatarUrl = "m.set_avatar_url"
        case change3Pid = "m.3pid_changes"

        static func doesNotContain(_ key: DynamicCodingKeys) -> Bool {
            !Self.allCases.map(\.stringValue).contains(key.stringValue)
        }
    }

    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // not used here, but a protocol requirement
        var intValue: Int?
        init?(intValue _: Int) {
            nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        changePassword = try container.decodeIfPresent(BooleanCapability.self, forKey: .changePassword)
        roomVersions = try container.decodeIfPresent(RoomVersionsCapability.self, forKey: .roomVersions)

        extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)

        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(
                AnyCodable.self,
                forKey: DynamicCodingKeys(stringValue: key.stringValue)!
            )
            self.extraInfo[key.stringValue] = decoded
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encodeIfPresent(changePassword, forKey: .changePassword)
        try container.encodeIfPresent(roomVersions, forKey: .roomVersions)

        var extraContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (name, value) in extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}

public extension MatrixCapabilities.Capabilities.BooleanCapability {
    internal enum CodingKeys: String, CodingKey {
        case enabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decode(Bool.self, forKey: .enabled)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabled, forKey: .enabled)
    }
}
