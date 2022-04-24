//
//  WhoAmI.swift
//  
//
//  Created by Finn Behrens on 23.04.22.
//

import Foundation

public struct MatrixWhoAmIRequest: MatrixRequest {
    public func components(for homeserver: MatrixHomeserver, with parameters: ()) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/account/whoami")
    }

    public static var httpMethod: HttpMethod {
        .GET
    }

    public static var requiresAuth: Bool {
        true
    }

    public typealias Response = MatrixWhoAmI

    public typealias URLParameters = ()
}

public struct MatrixWhoAmI: MatrixResponse {
    /// Device ID associated with the access token.
    ///
    /// If no device is associated with the access token (such as in the case of application services) then this field can be omitted. Otherwise this is required.
    public var deviceID: String?

    /// When true, the user is a Guest User.
    ///
    /// When not present or false, the user is presumed to be a non-guest user.
    public var isGuest: Bool? = false

    /// The user ID that owns the access token.
    public var userID: MatrixFullUserIdentifier

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case isGuest = "is_guest"
        case userID = "user_id"
    }
}
