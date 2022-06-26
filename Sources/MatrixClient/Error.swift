//
//  Error.swift
//  Error
//
//  Created by Finn Behrens on 07.08.21.
//

import AnyCodable
import Foundation

public enum MatrixCommonErrorCode: String, Error, Codable {
    // MARK: Common error codes

    /// Forbidden access, e.g. joining a room without permission, failed login.
    case forbidden = "M_FORBIDDEN"
    /// The access token specified was not recognised.
    ///
    /// An additional response parameter, soft_logout, might be present on the response for 401 HTTP status codes.
    case unknownToken = "M_UNKNOWN_TOKEN"
    /// No access token was specified for the request.
    case missingToken = "M_MISSING_TOKEN"
    /// Request contained valid JSON, but it was malformed in some way, e.g. missing required keys, invalid values for keys.
    case badJSON = "M_BAD_JSON"
    /// Request did not contain valid JSON.
    case notJSON = "M_NOT_JSON"
    /// No resource was found for this request.
    case notFound = "M_NOT_FOUND"
    /// Too many requests have been sent in a short period of time. Wait a while then try again.
    case limitExceeded = "M_LIMIT_EXCEEDED"
    /// An unknown error has occurred.
    case unknown = "M_UNKNOWN"

    // MARK: Other error codes

    /// The server did not understand the request.
    case unrecognized = "M_UNRECOGNIZED"
    /// The request was not correctly authorized. Usually due to login failures.
    case unauthorized = "M_UNAUTHORIZED"
    /// Encountered when trying to register a user ID which has been taken.
    case userInUse = "M_USER_IN_USE"
    /// Encountered when trying to register a user ID which is not valid.
    case invalidUserName = "M_INVALID_USERNAME"
    /// Sent when the room alias given to the createRoom API is already in use.
    case roomInUse = "M_ROOM_IN_USE"
    /// Sent when the initial state given to the createRoom API is invalid.
    case invalidRoomState = "M_INVALID_ROOM_STATE"
    /// Sent when a threepid given to an API cannot be used because the same threepid is already in use.
    case threePIDInUse = "M_THREEPID_IN_USE"
    /// Sent when a threepid given to an API cannot be used because no record matching the threepid was found.
    case threePIDNotFound = "M_THREEPID_NOT_FOUND"
    /// Authentication could not be performed on the third party identifier.
    case threePIDAuthFailed = "M_THREEPID_AUTH_FAILED"
    /// The server does not permit this third party identifier.
    ///
    /// This may happen if the server only permits, for example, email addresses from a particular domain.
    case threePIDDenied = "M_THREEPID_DENIED"
    /// The client’s request used a third party server, e.g. identity server, that this server does not trust.
    case serverNotTrusted = "M_SERVER_NOT_TRUSTED"
    /// The client’s request to create a room used a room version that the server does not support.
    case unsupportedRoomVersion = "M_UNSUPPORTED_ROOM_VERSION"
    /// The client attempted to join a room that has a version the server does not support.
    ///
    /// Inspect the `room_version` property of the error response for the room’s version.
    case incompatibleRoomVersion = "M_INCOMPATIBLE_ROOM_VERSION"
    /// The state change requested cannot be performed, such as attempting to unban a user who is not banned.
    case badState = "M_BAD_STATE"
    /// The room or resource does not permit guests to access it.
    case guestAccessForbidden = "M_GUEST_ACCESS_FORBIDDEN"
    /// A Captcha is required to complete the request.
    case captchaNeeded = "M_CAPTCHA_NEEDED"
    /// The Captcha provided did not match what was expected.
    case captchaInvalid = "M_CAPTCHA_INVALID"
    /// A required parameter was missing from the request.
    case missingParam = "M_MISSING_PARAM"
    /// A parameter that was specified has the wrong value.
    ///
    /// For example, the server expected an integer and instead received a string.
    case invalidParam = "M_INVALID_PARAM"
    /// The request or entity was too large.
    case tooLarge = "M_TOO_LARGE"
    /// The resource being requested is reserved by an application service,
    /// or the application service making the request has not created the resource.
    case exclusive = "M_EXCLUSIVE"
    /// The request cannot be completed because the homeserver has reached a resource limit imposed on it.
    ///
    /// For example, a homeserver held in a shared hosting environment may reach a resource limit if it starts using too much
    /// memory or disk space. The error MUST have an `admin_contact` field to provide the user receiving the error a
    /// place to reach out to. Typically, this error will appear on routes which attempt to modify
    /// state (e.g.: sending messages, account data, etc) and not routes which only read
    /// state (e.g.: /sync, get account data, etc).
    case resourceLimitExceeded = "M_RESOURCE_LIMIT_EXCEEDED"
    /// The user is unable to reject an invite to join the server notices room.
    case cannotLeaveServerNoticeRoom = "M_CANNOT_LEAVE_SERVER_NOTICE_ROOM"

    case badPagination = "M_BAD_PAGINATON"
    case oldVersion = "M_OLD_VERSION"
    case loginEmailURLNotYet = "M_LOGIN_EMAIL_URL_NOT_YET"
    case consentNotGiven = "M_CONSENT_NOT_GIVEN"
    case backupWrongKeysVersion = "M_WRONG_ROOM_KEYS_VERSION"
    case passwordTooShort = "M_PASSWORD_TOO_SHORT"
    case passwordNoDigit = "M_PASSWORD_NO_DIGIT"
    case passwordNoUppercase = "M_PASSWORD_NO_UPPERCASE"
    case passwordNoLowercase = "M_PASSWORD_NO_LOWERCASE"
    case passwordNoSymbol = "M_PASSWORD_NO_SYMBOL"
    case passwordInDictionary = "M_PASSWORD_IN_DICTIONARY"
    case passwordWeak = "M_WEAK_PASSWORD"
    case termsNotSigned = "M_TERMS_NOT_SIGNED"
    case invalidPepper = "M_INVALID_PEPPER"
    
    // MSC 3575
    case unknownPos = "M_UNKNOWN_POS"
}

public struct MatrixErrorCode: RawRepresentable, Error, Codable {
    public private(set) var common: MatrixCommonErrorCode?
    var string: String?

    public var rawValue: String {
        if let common = common {
            return common.rawValue
        }
        return string!
    }

    public init?(rawValue: String) {
        common = MatrixCommonErrorCode(rawValue: rawValue)
        if common == nil {
            string = rawValue
        }
    }

    public init(_ common: MatrixCommonErrorCode) {
        self.common = common
    }
}

public extension MatrixErrorCode {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension MatrixErrorCode: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)!
    }
}

public extension MatrixErrorCode {
    // MARK: Common error codes

    /// Forbidden access, e.g. joining a room without permission, failed login.
    static let Forbidden = MatrixErrorCode(.forbidden)
    /// The access token specified was not recognised.
    ///
    /// An additional response parameter, soft_logout, might be present on the response for 401 HTTP status codes.
    static let UnknownToken = MatrixErrorCode(.unknownToken)
    /// No access token was specified for the request.
    static let MissingToken = MatrixErrorCode(.missingToken)
    /// Request contained valid JSON, but it was malformed in some way, e.g. missing required keys, invalid values for keys.
    static let BadJSON = MatrixErrorCode(.badJSON)
    /// Request did not contain valid JSON.
    static let NotJSON = MatrixErrorCode(.notJSON)
    /// No resource was found for this request.
    static let NotFound = MatrixErrorCode(.notFound)
    /// Too many requests have been sent in a short period of time. Wait a while then try again.
    static let LimitExceeded = MatrixErrorCode(.limitExceeded)
    /// An unknown error has occurred.
    static let Unknown = MatrixErrorCode(.unknown)

    // MARK: Other error codes

    /// The server did not understand the request.
    static let Unrecognized = MatrixErrorCode(.unrecognized)
    /// The request was not correctly authorized. Usually due to login failures.
    static let Unauthorized = MatrixErrorCode(.unauthorized)
    /// Encountered when trying to register a user ID which has been taken.
    static let UserInUse = MatrixErrorCode(.userInUse)
    /// Encountered when trying to register a user ID which is not valid.
    static let InvalidUserName = MatrixErrorCode(.invalidUserName)
    /// Sent when the room alias given to the createRoom API is already in use.
    static let RoomInUse = MatrixErrorCode(.roomInUse)
    /// Sent when the initial state given to the createRoom API is invalid.
    static let InvalidRoomState = MatrixErrorCode(.invalidRoomState)
    /// Sent when a threepid given to an API cannot be used because the same threepid is already in use.
    static let ThreePIDInUse = MatrixErrorCode(.threePIDInUse)
    /// Sent when a threepid given to an API cannot be used because no record matching the threepid was found.
    static let ThreePIDNotFound = MatrixErrorCode(.threePIDNotFound)
    /// Authentication could not be performed on the third party identifier.
    static let ThreePIDAuthFailed = MatrixErrorCode(.threePIDAuthFailed)
    /// The server does not permit this third party identifier.
    ///
    /// This may happen if the server only permits, for example, email addresses from a particular domain.
    static let ThreePIDDenied = MatrixErrorCode(.threePIDDenied)
    /// The client’s request used a third party server, e.g. identity server, that this server does not trust.
    static let ServerNotTrusted = MatrixErrorCode(.serverNotTrusted)
    /// The client’s request to create a room used a room version that the server does not support.
    static let UnsupportedRoomVersion = MatrixErrorCode(.unsupportedRoomVersion)
    /// The client attempted to join a room that has a version the server does not support.
    ///
    /// Inspect the `room_version` property of the error response for the room’s version.
    static let IncompatibleRoomVersion = MatrixErrorCode(.incompatibleRoomVersion)
    /// The state change requested cannot be performed, such as attempting to unban a user who is not banned.
    static let BadState = MatrixErrorCode(.badState)
    /// The room or resource does not permit guests to access it.
    static let GuestAccessForbidden = MatrixErrorCode(.guestAccessForbidden)
    /// A Captcha is required to complete the request.
    static let CaptchaNeeded = MatrixErrorCode(.captchaNeeded)
    /// The Captcha provided did not match what was expected.
    static let CaptchaInvalid = MatrixErrorCode(.captchaInvalid)
    /// A required parameter was missing from the request.
    static let MissingParam = MatrixErrorCode(.missingParam)
    /// A parameter that was specified has the wrong value.
    ///
    /// For example, the server expected an integer and instead received a string.
    static let InvalidParam = MatrixErrorCode(.invalidParam)
    /// The request or entity was too large.
    static let TooLarge = MatrixErrorCode(.tooLarge)
    /// The resource being requested is reserved by an application service,
    /// or the application service making the request has not created the resource.
    static let Exclusive = MatrixErrorCode(.exclusive)
    /// The request cannot be completed because the homeserver has reached a resource limit imposed on it.
    ///
    /// For example, a homeserver held in a shared hosting environment may reach a resource limit if it starts using too much
    /// memory or disk space. The error MUST have an `admin_contact` field to provide the user receiving the error a
    /// place to reach out to. Typically, this error will appear on routes which attempt to modify
    /// state (e.g.: sending messages, account data, etc) and not routes which only read
    /// state (e.g.: /sync, get account data, etc).
    static let ResourceLimitExceeded = MatrixErrorCode(.resourceLimitExceeded)
    /// The user is unable to reject an invite to join the server notices room.
    static let CannotLeaveServerNoticeRoom = MatrixErrorCode(.cannotLeaveServerNoticeRoom)

    static let BadPagination = MatrixErrorCode(.badPagination)
    static let OldVersion = MatrixErrorCode(.oldVersion)
    static let LoginEmailURLNotYet = MatrixErrorCode(.loginEmailURLNotYet)
    static let ConsentNotGiven = MatrixErrorCode(.consentNotGiven)
    static let BackupWrongKeysVersion = MatrixErrorCode(.backupWrongKeysVersion)
    static let PasswordTooShort = MatrixErrorCode(.passwordTooShort)
    static let PasswordNoDigit = MatrixErrorCode(.passwordNoDigit)
    static let PasswordNoUppercase = MatrixErrorCode(.passwordNoUppercase)
    static let PasswordNoLowercase = MatrixErrorCode(.passwordNoLowercase)
    static let PasswordNoSymbol = MatrixErrorCode(.passwordNoSymbol)
    static let PasswordInDictionary = MatrixErrorCode(.passwordInDictionary)
    static let PasswordWeak = MatrixErrorCode(.passwordWeak)
    static let TermsNotSigned = MatrixErrorCode(.termsNotSigned)
    static let InvalidPepper = MatrixErrorCode(.invalidPepper)
}

public struct MatrixServerError: Error, Codable {
    public init(errcode: MatrixErrorCode, error: String, code: Int? = nil, extraInfo: [String: AnyCodable] = [:]) {
        self.errcode = errcode
        self.error = error
        self.code = code
        self.extraInfo = extraInfo
    }

    /// Error code
    public var errcode: MatrixErrorCode

    /// Error message  reported by the server
    public var error: String

    /// HTTP status code
    public var code: Int?

    public var interactiveAuth: MatrixInteractiveAuth?

    public var extraInfo: [String: AnyCodable]

    // TODO: extra data

    public init(json: Data, code: Int? = nil) throws {
        let decoder = JSONDecoder()
        decoder.userInfo[.matrixErrorHttpCode] = code

        do {
            self = try decoder.decode(Self.self, from: json)
        } catch {
            throw MatrixServerError(
                errcode: .Unknown,
                error: error.localizedDescription,
                code: code,
                extraInfo: ["json": .init(json)]
            )
        }
        self.code = code
    }
}

public extension MatrixServerError {
    internal enum KnownCodingKeys: String, MatrixKnownCodingKeys {
        case errcode
        case error

        static let extraIgnoreValues = [
            "session",
            "flows",
            "params",
            "completed",
        ]

        static func doesNotContain(_ key: MatrixDynamicCodingKeys) -> Bool {
            !Self.allCases.map(\.stringValue).contains(key.stringValue) && !Self.extraIgnoreValues
                .contains(key.stringValue)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        errcode = try container.decodeIfPresent(MatrixErrorCode.self, forKey: .errcode) ?? .Unknown
        error = try container.decodeIfPresent(String.self, forKey: .error) ?? ""

        extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: MatrixDynamicCodingKeys.self)

        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(
                AnyCodable.self,
                forKey: .init(stringValue: key.stringValue)!
            )
            self.extraInfo[key.stringValue] = decoded
        }

        guard let code = decoder.userInfo[.matrixErrorHttpCode] as? Int,
              code == 401
        else {
            return
        }

        do {
            interactiveAuth = try MatrixInteractiveAuth(from: decoder)
        } catch {
            // don't care if it fails
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encode(errcode, forKey: .errcode)
        try container.encode(error, forKey: .error)

        var extraContainer = encoder.container(keyedBy: MatrixDynamicCodingKeys.self)
        for (name, value) in extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}

public extension MatrixServerError {
    var is401: Bool {
        errcode == .Unauthorized && code == 401
    }

    var is404: Bool {
        errcode == .NotFound && code == 404
    }

    var isTokenError: Bool {
        errcode == .UnknownToken || errcode == .MissingToken
    }

    var isLimitexceededError: Bool {
        code == 429 && errcode == .LimitExceeded
    }

    var shouldbeRetried: Bool {
        // Investigate network error codes
        isLimitexceededError
    }
}

extension CodingUserInfoKey {
    /// The key used to determine the types of `MatrixEvent` that can be decoded.
    static var matrixErrorHttpCode: CodingUserInfoKey {
        CodingUserInfoKey(rawValue: "MatrixClient.ErrorHttpCode")!
    }
}
