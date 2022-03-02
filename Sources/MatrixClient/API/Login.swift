//
//  File.swift
//  File
//
//  Created by Finn Behrens on 27.09.21.
//

import Foundation

public struct MatrixLoginFlowRequest: MatrixRequest {
    public typealias Response = Self.ResponseStruct
    
    public typealias URLParameters = ()
    
    public func components(for homeserver: MatrixHomeserver, with parameters: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/r0/login"
        return components
    }
    
    public static var httpMethod = HttpMethod.GET
    
    public static var requiresAuth = false
    
    public struct ResponseStruct: MatrixResponse {
        var flows: [FlowType]
        
        struct FlowType: Codable {
            var type: MatrixLoginFlow
        }
    }
}

@frozen
/// A login type supported by the homeserver.
public struct MatrixLoginFlow: RawRepresentable, Codable, Equatable {
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
    public static let password: MatrixLoginFlow = "m.login.password"
    
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
    public static let recaptcha: MatrixLoginFlow = "m.login.recaptcha"
    public static let oauth2: MatrixLoginFlow = "m.login.oauth2"
    
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
    public static let sso: MatrixLoginFlow = "m.login.sso"
    public static let email: MatrixLoginFlow = "m.login.email.identity"
    public static let msisdn: MatrixLoginFlow = "m.login.msisdn"
    public static let token: MatrixLoginFlow = "m.login.token"
    public static let dummy: MatrixLoginFlow = "m.login.dummy"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension MatrixLoginFlow: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
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
        case .user(id: let id):
            try container.encode("m.id.user", forKey: .type)
            try container.encode(id, forKey: .user)
        case .thirdparty(medium: let medium, address: let address):
            try container.encode("m.id.thirdparty", forKey: .type)
            try container.encode(medium, forKey: .medium)
            try container.encode(address, forKey: .address)
        case .phone(country: let country, phone: let phone):
            try container.encode("m.id.phone", forKey: .type)
            try container.encode(country, forKey: .country)
            try container.encode(phone, forKey: .phone)
        }
    }
}

public struct MatrixLoginRequest {
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
    
    public func components(for homeserver: MatrixHomeserver, with parameters: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/r0/login"
        return components
    }
    
    public static var httpMethod = HttpMethod.POST
    
    public static var requiresAuth = false
}

public struct MatrixLogin: MatrixResponse {
    /// The fully-qualified Matrix ID that has been registered.
    public var userId: String?
    
    /// An access token for the account. This access token can then be used to authorize other requests.
    public var accessToken: String?
    
    /// The server_name of the homeserver on which the account has been registered.
    @available(*, deprecated, message: "Clients should extract the server_name from userId (by splitting at the first colon) if they require it.")
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
