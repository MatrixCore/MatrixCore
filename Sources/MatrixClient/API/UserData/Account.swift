//
//  Account.swift
//
//
//  Created by Finn Behrens on 30.03.22.
//

import Foundation

public struct MatrixGetDisplayName: MatrixRequest, MatrixResponse {
    public func components(for homeserver: MatrixHomeserver, with userID: String) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/profile/\(userID)/displayname")
    }

    public static var httpMethod: HttpMethod {
        .GET
    }

    public static var requiresAuth: Bool {
        false
    }

    public typealias Response = MatrixSetDisplayName

    public typealias URLParameters = String
}

public struct MatrixSetDisplayName: MatrixRequest, MatrixResponse {
    public var displayname: String

    public func components(for homeserver: MatrixHomeserver, with userID: String) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/profiles/\(userID)/displayname")
    }

    public static var httpMethod: HttpMethod {
        .PUT
    }

    public static var requiresAuth: Bool {
        true
    }

    public typealias Response = MatrixGetDisplayName
}
