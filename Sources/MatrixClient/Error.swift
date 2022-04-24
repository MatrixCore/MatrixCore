//
//  Error.swift
//  Error
//
//  Created by Finn Behrens on 07.08.21.
//

import Foundation

public enum MatrixCommonErrorCode: String, Error, Codable {
    case Forbidden = "M_FORBIDDEN"
    case Unknown = "M_UNKNOWN"
    case UnknownToken = "M_UNKNOWN_TOKEN"
    case BadJSON = "M_BAD_JSON"
    case NotFound = "M_NOT_FOUND"
    case LimitExceeded = "M_LIMIT_EXCEEDED"
    case UserInUse = "M_USER_IN_USE"
    case RoomInUse = "M_ROOM_IN_USE"
    case BadPagination = "M_BAD_PAGINATON"
    case Unauthorized = "M_UNAUTHORIZED"
    case OldVersion = "M_OLD_VERSION"
    case Unrecognized = "M_UNRECOGNIZED"
    case LoginEmailURLNotYet = "M_LOGIN_EMAIL_URL_NOT_YET"
    case ThreePIDAuthFailed = "M_THREEPID_AUTH_FAILED"
    case ThreePIDInUse = "M_THREEPID_IN_USE"
    case ThreePIDNotFound = "M_THREEPID_NOT_FOUND"
    case ServerNotTrusted = "M_SERVER_NOT_TRUSTED"
    case GuestAccessForbidden = "M_GUEST_ACCESS_FORBIDDEN"
    case ConsentNotGiven = "M_CONSENT_NOT_GIVEN"
    case ResourceLimitExceeded = "M_RESOURCE_LIMIT_EXCEEDED"
    case BackupWrongKeysVersion = "M_WRONG_ROOM_KEYS_VERSION"
    case PasswordTooShort = "M_PASSWORD_TOO_SHORT"
    case PasswordNoDigit = "M_PASSWORD_NO_DIGIT"
    case PasswordNoUppercase = "M_PASSWORD_NO_UPPERCASE"
    case PasswordNoLowercase = "M_PASSWORD_NO_LOWERCASE"
    case PasswordNoSymbol = "M_PASSWORD_NO_SYMBOL"
    case PasswordInDictionary = "M_PASSWORD_IN_DICTIONARY"
    case PasswordWeak = "M_WEAK_PASSWORD"
    case TermsNotSigned = "M_TERMS_NOT_SIGNED"
    case InvalidPepper = "M_INVALID_PEPPER"
    case Exclusive = "M_EXCLUSIVE"
    case InvalidParam = "M_INVALID_PARAM"
}

public struct MatrixErrorCode: RawRepresentable, Error, Codable {
    var common: MatrixCommonErrorCode?
    var string: String?

    public var rawValue: String {
        if let common = common {
            return common.rawValue
        }
        return string!
    }

    public init?(rawValue: String) {
        self.common = MatrixCommonErrorCode(rawValue: rawValue)
        if common == nil {
            self.string = rawValue
        }
    }

    public init(_ common: MatrixCommonErrorCode) {
        self.common = common
    }
}

extension MatrixErrorCode {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension MatrixErrorCode: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)!
    }
}

public extension MatrixErrorCode {
    static let Forbidden = MatrixErrorCode(.Forbidden)
    static let Unknown = MatrixErrorCode(.Unknown)
    static let UnknownToken = MatrixErrorCode(.UnknownToken)
    static let BadJSON = MatrixErrorCode(.BadJSON)
    static let NotFound = MatrixErrorCode(.NotFound)
    static let LimitExceeded = MatrixErrorCode(.LimitExceeded)
    static let UserInUse = MatrixErrorCode(.UserInUse)
    static let RoomInUse = MatrixErrorCode(.RoomInUse)
    static let BadPagination = MatrixErrorCode(.BadPagination)
    static let Unauthorized = MatrixErrorCode(.Unauthorized)
    static let OldVersion = MatrixErrorCode(.OldVersion)
    static let Unrecognized = MatrixErrorCode(.Unrecognized)
    static let LoginEmailURLNotYet = MatrixErrorCode(.LoginEmailURLNotYet)
    static let ThreePIDAuthFailed = MatrixErrorCode(.ThreePIDAuthFailed)
    static let ThreePIDInUse = MatrixErrorCode(.ThreePIDInUse)
    static let ThreePIDNotFound = MatrixErrorCode(.ThreePIDNotFound)
    static let ServerNotTrusted = MatrixErrorCode(.ServerNotTrusted)
    static let GuestAccessForbidden = MatrixErrorCode(.GuestAccessForbidden)
    static let ConsentNotGiven = MatrixErrorCode(.ConsentNotGiven)
    static let ResourceLimitExceeded = MatrixErrorCode(.ResourceLimitExceeded)
    static let BackupWrongKeysVersion = MatrixErrorCode(.BackupWrongKeysVersion)
    static let PasswordTooShort = MatrixErrorCode(.PasswordTooShort)
    static let PasswordNoDigit = MatrixErrorCode(.PasswordNoDigit)
    static let PasswordNoUppercase = MatrixErrorCode(.PasswordNoUppercase)
    static let PasswordNoLowercase = MatrixErrorCode(.PasswordNoLowercase)
    static let PasswordNoSymbol = MatrixErrorCode(.PasswordNoSymbol)
    static let PasswordInDictionary = MatrixErrorCode(.PasswordInDictionary)
    static let PasswordWeak = MatrixErrorCode(.PasswordWeak)
    static let TermsNotSigned = MatrixErrorCode(.TermsNotSigned)
    static let InvalidPepper = MatrixErrorCode(.InvalidPepper)
    static let Exclusive = MatrixErrorCode(.Exclusive)
    static let InvalidParam = MatrixErrorCode(.InvalidParam)
}

public struct MatrixServerError: Error, Codable {
    /// Error code
    public var errcode: MatrixErrorCode

    /// Error message  reported by the server
    public var error: String

    /// HTTP status code
    public var code: Int?

    // TODO: extra data

    public init(json: Data, code: Int? = nil) throws {
        let decoder = JSONDecoder()

        do {
            self = try decoder.decode(Self.self, from: json)
        } catch {
            throw MatrixInvalidError(data: json, code: code)
        }
        self.code = code
    }
}

public struct MatrixInvalidError: Error, LocalizedError {
    public var data: Data
    public var code: Int?

    public init(data: Data, code: Int? = nil) {
        self.data = data
        self.code = code
    }

    var localisedDescription: String {
        NSLocalizedString("Failed to parse error result for code \(code ?? -1)", comment: "MatrixInvalidError")
    }
}
