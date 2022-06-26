//
//  File.swift
//  File
//
//  Created by Finn Behrens on 27.09.21.
//

import Foundation
import AnyCodable

public struct MatrixLoginFlowRequest {
    public struct ResponseStruct: MatrixResponse {
        var flows: [MatrixLoginFlow]
    }
}

extension MatrixLoginFlowRequest: MatrixRequest {
    public typealias Response = Self.ResponseStruct

    public typealias URLParameters = ()

    public func components(for homeserver: MatrixHomeserver, with _: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/r0/login"
        return components
    }

    public static var httpMethod = HttpMethod.GET

    public static var requiresAuth = false
}

@frozen
/// A login type supported by the homeserver.
public struct MatrixLoginFlowType: RawRepresentable, Codable, Equatable, Hashable {
    public typealias RawValue = String

    public var rawValue: String

    /// The client submits an identifier and secret password, both sent in plain-text.
    ///
    /// To use this authentication type, clients should submit an auth dict as follows:
    /// ```json
    /// {
    ///     "type": "m.login.password",
    ///     "identifier": {
    ///         ...
    ///     },
    ///     "password": "<password>",
    ///     "session": "<session ID>"
    /// }
    /// ```
    ///
    /// Alternatively reply using a 3PID bound to the user's account on the homeserver using the /account/3pid API rather then giving the user explicitly as follows:
    /// ```json
    /// {
    ///     "type": "m.login.password",
    ///     "identifier": {
    ///         "type": "m.id.thirdparty",
    ///         "medium": "<The medium of the third party identifier.>",
    ///         "address": "<The third party address of the user>"
    ///     },
    ///     "password": "<password>",
    ///     "session": "<session ID>"
    ///     }
    /// ```
    /// In the case that the homeserver does not know about the supplied 3PID, the homeserver must respond with 403 Forbidden.
    public static let password: MatrixLoginFlowType = "m.login.password"

    /// The user completes a Google ReCaptcha 2.0 challenge
    ///
    /// To use this authentication type, clients should submit an auth dict as follows:
    /// ```json
    /// {
    ///     "type": "m.login.recaptcha",
    ///     "response": "<captcha response>",
    ///     "session": "<session ID>"
    /// }
    /// ```
    public static let recaptcha: MatrixLoginFlowType = "m.login.recaptcha"
    public static let oauth2: MatrixLoginFlowType = "m.login.oauth2"

    /// Authentication is supported by authorising with an external single sign-on provider.
    ///
    /// A client wanting to complete authentication using SSO should use the Fallback authentication flow by opening a browser window for `/_matrix/client/r0/auth/m.login.sso/fallback/web?session=<...>` with the session parameter set to the session ID provided by the server.
    /// The homeserver should return a page which asks for the user's confirmation before proceeding. For example, the page could say words to the effect of:
    ///
    ///    A client is trying to remove a device/add an email address/take over your account. To confirm this action, re-authenticate with single sign-on. If you did not expect this, your account may be compromised!
    ///
    ///    Once the user has confirmed they should be redirected to the single sign-on provider's login page. Once the provider has validated the user, the browser is redirected back to the homeserver.
    ///
    ///    The homeserver then validates the response from the single sign-on provider and updates the user-interactive authentication session to mark the single sign-on stage has been completed. The browser is shown the fallback authentication completion page.
    ///
    ///    Once the flow has completed, the client retries the request with the session only, as above.
    public static let sso: MatrixLoginFlowType = "m.login.sso"
    public static let email: MatrixLoginFlowType = "m.login.email.identity"
    public static let msisdn: MatrixLoginFlowType = "m.login.msisdn"
    public static let token: MatrixLoginFlowType = "m.login.token"
    public static let dummy: MatrixLoginFlowType = "m.login.dummy"
    public static let terms: MatrixLoginFlowType = "m.login.terms"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MatrixLoginFlowType: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        rawValue = value
    }
}

public struct MatrixLoginFlow {
    public init(type: MatrixLoginFlowType, identiyProviders: [MatrixLoginFlow.IdentityProvider]? = nil, extraInfo: [String : AnyCodable] = [:]) {
        self.type = type
        self.identiyProviders = identiyProviders
        self.extraInfo = extraInfo
    }
    
    public var type: MatrixLoginFlowType
    
    public var identiyProviders: [IdentityProvider]?
    
    public var extraInfo: [String: AnyCodable]
    
    public struct IdentityProvider: Codable, Identifiable {
        public init(brand: Brand? = nil, icon: MatrixContentURL? = nil, id: String, name: String) {
            self.brand = brand
            self.icon = icon
            self.id = id
            self.name = name
        }
        
        /// Optional UI hint for what kind of common SSO provider is being described in this ``IdentityProvider``.
        ///
        /// Matrix maintains a registry of identifiers in the
        /// [matrix-spec repo](https://github.com/matrix-org/matrix-spec/blob/main/informal/idp-brands.md) to ensure clients and servers are aligned on major/common brands.
        ///
        /// Clients should prefer the brand over the icon, when both are provided.
        /// Clients are not required to support any particular brand, including those in the registry, though are expected to be able to present any IdP based off the name/icon to the user regardless.
        ///
        /// Unregistered brands are permitted using the Common Namespaced Identifier Grammar, though excluding the namespace requirements. For example, examplesso is a valid brand which is not in the registry but still permitted. Servers should be mindful that clients might not support their unregistered brand usage as intended by the server.
        public var brand: Brand?
        
        /// Optional MXC URI to provide an image/icon representing the ``IdentityProvider``. Intended to be shown alongside the name if provided.
        public var icon: MatrixContentURL?
        
        /// Opaque string chosen by the homeserver, uniquely identifying the ``IdentityProvider`` from other ``IdentityProvider``s the homeserver might support.
        ///
        /// Should be between 1 and 255 characters in length, containing unreserved characters under RFC 3986 (ALPHA DIGIT "-" / "." / "_" / "~"). Clients are not intended to parse or infer meaning from opaque strings.
        public var id: String
        
        /// Human readable description for the ``IdentityProvider``, intended to be shown to the user.
        public var name: String
        
        @frozen
        public struct Brand: RawRepresentable, Codable, Identifiable, ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {
            public init?(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(stringLiteral value: StringLiteralType) {
                self.rawValue = value
            }
        
            public var rawValue: String
            
            public var id: String {
                rawValue
            }
            
            public var description: String {
                rawValue
            }
            
            // MARK: Brand Registry
            /// Apple
            ///
            /// Suitable for "Sign in with Apple": see
            /// [https://appleid.apple.com/signinwithapple/button](https://appleid.apple.com/signinwithapple/button).
            public static let apple: Self = "apple"
            
            /// Facebok
            ///
            /// "Continue with Facebook": see https://developers.facebook.com/docs/facebook-login/web/login-button/.
            public static let facebook: Self = "facebook"
            
            /// GitHub
            ///
            /// Logos available at https://github.com/logos.
            public static let github: Self = "github"
            
            /// GitLab
            ///
            /// Logos available at https://about.gitlab.com/press/press-kit/.
            public static let gitlab: Self = "gitlab"
            
            /// Google
            ///
            /// Suitable for "Google Sign-In": see https://developers.google.com/identity/branding-guidelines.
            public static let google: Self = "google"
            
            /// Twitter
            ///
            /// Suitable for "Log in with Twitter": see https://developer.twitter.com/en/docs/authentication/guides/log-in-with-twitter#tab1.
            public static let twitter: Self = "twitter"
        }
    }
}

extension MatrixLoginFlow: Codable {
    private enum KnownCodingKeys: String, MatrixKnownCodingKeys {
        case type
        case identiyProviders = "identity_providers"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        type = try container.decode(MatrixLoginFlowType.self, forKey: .type)
        identiyProviders = try container.decodeIfPresent([IdentityProvider].self, forKey: .identiyProviders)

        extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: MatrixDynamicCodingKeys.self)

        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(
                AnyCodable.self,
                forKey: MatrixDynamicCodingKeys(stringValue: key.stringValue)!
            )
            self.extraInfo[key.stringValue] = decoded
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(identiyProviders, forKey: .identiyProviders)

        var extraContainer = encoder.container(keyedBy: MatrixDynamicCodingKeys.self)
        for (name, value) in extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}

public enum MatrixLoginUserIdentifier: Codable {
    /// 5.4.6.1 Matrix User id
    ///
    /// A client can identify a user using their Matrix ID. This can either be the fully qualified Matrix user ID, or just the localpart of the user ID.
    ///
    /// **Type**: `m.id.user`
    case user(id: String)

    /// 5.4.6.2 Third-party ID
    ///
    /// A client can identify a user using a 3PID associated with the user's account on the homeserver, where the 3PID was previously associated
    /// using the /account/3pid API. See the 3PID Types Appendix for a list of Third-party ID media.
    ///
    /// **Type**: `m.id.thirdparty`
    case thirdparty(medium: String, address: String)

    /// 5.4.6.3 Phone number
    ///
    /// A client can identify a user using a phone number associated with the user's account, where the phone number was previously associated
    /// using the /account/3pid API. The phone number can be passed in as entered by the user; the homeserver will be responsible for
    /// canonicalising it. If the client wishes to canonicalise the phone number, then it can use the m.id.thirdparty identifier type with a medium o
    /// msisdn instead.
    ///
    /// **Type**: `m.id.phone`
    case phone(country: String, phone: String)

    private enum CodingKeys: String, CodingKey {
        case type
        case user
        case medium
        case address
        case country
        case phone
    }

    enum MatrixLoginUserIdentifierError: Error {
        case decodingInvalidType(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)

        switch type {
        case "m.id.user":
            let id = try values.decode(String.self, forKey: .user)
            self = .user(id: id)
            return
        case "m.id.thirdparty":
            let medium = try values.decode(String.self, forKey: .medium)
            let address = try values.decode(String.self, forKey: .address)
            self = .thirdparty(medium: medium, address: address)
            return
        case "m.id.phone":
            let country = try values.decode(String.self, forKey: .country)
            let phone = try values.decode(String.self, forKey: .phone)
            self = .phone(country: country, phone: phone)
            return
        default:
            throw MatrixLoginUserIdentifierError.decodingInvalidType(type)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .user(id: id):
            try container.encode("m.id.user", forKey: .type)
            try container.encode(id, forKey: .user)
        case let .thirdparty(medium: medium, address: address):
            try container.encode("m.id.thirdparty", forKey: .type)
            try container.encode(medium, forKey: .medium)
            try container.encode(address, forKey: .address)
        case let .phone(country: country, phone: phone):
            try container.encode("m.id.phone", forKey: .type)
            try container.encode(country, forKey: .country)
            try container.encode(phone, forKey: .phone)
        }
    }
}

/// Login Request.
public struct MatrixLoginRequest {
    public init(
        type: String,
        identifier: MatrixLoginUserIdentifier? = nil,
        password: String? = nil,
        token: String? = nil,
        deviceId: String? = nil,
        initialDeviceDisplayName: String? = nil
    ) {
        self.type = type
        self.identifier = identifier
        self.password = password
        self.token = token
        self.deviceId = deviceId
        self.initialDeviceDisplayName = initialDeviceDisplayName
    }

    @available(*, deprecated, renamed: "init(type:identifier:password:token:deviceId:initialDeviceDisplayName:)")
    public init(
        type: String,
        user: String? = nil,
        medium: String? = nil,
        address: String? = nil,
        password: String? = nil,
        token: String? = nil,
        deviceId: String? = nil,
        initialDeviceDisplayName: String? = nil
    ) {
        self.type = type
        self.user = user
        self.medium = medium
        self.address = address
        self.password = password
        self.token = token
        self.deviceId = deviceId
        self.initialDeviceDisplayName = initialDeviceDisplayName
    }

    /// The login type being used. One of: ["m.login.password", "m.login.token"]
    public var type: String

    /// Identification information for the user.
    public var identifier: MatrixLoginUserIdentifier?

    /// The fully qualified user ID or just local part of the user ID, to log in.
    @available(*, deprecated, message: "Deprecated in favour of identifier.", renamed: "identifier")
    public var user: String?

    /// When logging in using a third party identifier, the medium of the identifier. Must be 'email'.
    @available(*, deprecated, message: "Deprecated in favour of identifier.", renamed: "identifier")
    public var medium: String?

    /// Third party identifier for the user
    @available(*, deprecated, message: "Deprecated in favour of identifier.", renamed: "identifier")
    public var address: String?

    /// Required when type is m.login.password. The user's password.
    public var password: String?

    /// Required when type is m.login.token. Part of Token-based login.
    public var token: String?

    /// ID of the client device. If this does not correspond to a known client device, a new device will be created.
    /// The server will auto-generate a device_id if this is not specified.
    public var deviceId: String?

    /// A display name to assign to the newly-created device. Ignored if device_id corresponds to a known device.
    public var initialDeviceDisplayName: String?

    enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case user
        case medium
        case address
        case password
        case token
        case deviceId = "device_id"
        case initialDeviceDisplayName = "initial_device_display_name"
    }
}

extension MatrixLoginRequest: MatrixRequest {
    public typealias Response = MatrixLogin

    public typealias URLParameters = ()

    public func components(for homeserver: MatrixHomeserver, with _: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/r0/login"
        return components
    }

    public static var httpMethod = HttpMethod.POST

    public static var requiresAuth = false
}

public struct MatrixLogin: MatrixResponse {
    public init(
        userId: MatrixFullUserIdentifier? = nil,
        accessToken: String? = nil,
        homeServer: String? = nil,
        deviceId: String? = nil,
        wellKnown: MatrixWellKnown? = nil
    ) {
        self.userId = userId
        self.accessToken = accessToken
        self.homeServer = homeServer
        self.deviceId = deviceId
        self.wellKnown = wellKnown
    }

    /// The fully-qualified Matrix ID that has been registered.
    public var userId: MatrixFullUserIdentifier?

    /// An access token for the account. This access token can then be used to authorise other requests.
    public var accessToken: String?

    /// The server_name of the homeserver on which the account has been registered.
    @available(
        *,
        deprecated,
        message: "Clients should extract the server_name from userId (by splitting at the first colon) if they require it.",
        renamed: "userID.domain"
    )
    public var homeServer: String?

    /// ID of the logged-in device. Will be the same as the corresponding parameter in the request, if one was specified.
    public var deviceId: String?

    /// Optional client configuration provided by the server. If present, clients SHOULD use the provided object to reconfigure
    /// themselves, optionally validating the URLs within. This object takes the same form as the one returned from .well-known autodiscovery.
    public var wellKnown: MatrixWellKnown?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case accessToken = "access_token"
        case homeServer = "home_server"
        case deviceId = "device_id"
        case wellKnown = "well_known"
    }
}
