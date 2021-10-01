//
//  Error.swift
//  Error
//
//  Created by Finn Behrens on 07.08.21.
//

import Foundation

public enum MatrixError: String, Error, Codable {
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
    
}

public struct MatrixServerError: Error, Codable {
    /// Error code
    public var errcode: MatrixError
    
    /// Error message  reported by the server
    public var error: String
    
    /// HTTP status code
    public var code: Int?
    
    // TODO: extra data
    
    public init(json: Data, code: Int? = nil) throws {
        let decoder = JSONDecoder()
        
        self = try decoder.decode(Self.self, from: json)
        self.code = code
    }
}

