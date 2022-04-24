//
//  File.swift
//
//
//  Created by Finn Behrens on 26.03.22.
//

import Foundation

public protocol MatrixAccountData: MatrixResponse {
    static var type: String { get }

    // TODO: optional room parameter?
}

// TODO: sync event wrapper

public struct MatrixGetAccountData<T: MatrixAccountData>: MatrixResponse, MatrixRequest {
    public typealias Response = T

    public static var httpMethod: HttpMethod {
        .GET
    }

    public static var requiresAuth: Bool {
        true
    }

    public func components(for homeserver: MatrixHomeserver,
                           with parameters: RequestParameter) throws -> URLComponents
    {
        guard let fqmxid = parameters.userID.FQMXID else {
            throw MatrixErrorCode.NotFound
        }

        if let roomID = parameters.roomID {
            return homeserver.path("/_matrix/client/v3/user/\(fqmxid)/rooms/\(roomID)/account_data/\(T.type)")
        } else {
            return homeserver.path("/_matrix/client/v3/user/\(fqmxid)/account_data/\(T.type)")
        }
    }

    public struct RequestParameter {
        var userID: MatrixUserIdentifier

        var roomID: String?
    }
}

public struct MatrixSetAccountData<T: MatrixAccountData>: MatrixRequest {
    var content: T

    public typealias Response = MatrixGetAccountData<T>

    public typealias URLParameters = MatrixGetAccountData<T>.RequestParameter

    public static var httpMethod: HttpMethod {
        .PUT
    }

    public static var requiresAuth: Bool {
        true
    }

    public func components(for homeserver: MatrixHomeserver,
                           with parameters: MatrixGetAccountData<T>.RequestParameter) throws -> URLComponents
    {
        guard let fqmxid = parameters.userID.FQMXID else {
            throw MatrixErrorCode.NotFound
        }

        if let roomID = parameters.roomID {
            return homeserver.path("/_matrix/client/v3/user/\(fqmxid)/rooms/\(roomID)/account_data/\(T.type)")
        } else {
            return homeserver.path("/_matrix/client/v3/user/\(fqmxid)/account_data/\(T.type)")
        }
    }
}

public extension MatrixAccountData {
    typealias Response = MatrixGetAccountData

    static var httpMethod: HttpMethod {
        .GET
    }

    static var requiresAuth: Bool {
        true
    }

    func components(for homeserver: MatrixHomeserver, with userID: MatrixUserIdentifier) throws -> URLComponents {
        guard let fqmxid = userID.FQMXID else {
            throw MatrixErrorCode.NotFound
        }
        return homeserver.path("/_matrix/client/v3/user/\(fqmxid)/account_data/\(Self.type)")
    }
}
