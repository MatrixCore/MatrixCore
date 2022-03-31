//
//  File.swift
//
//
//  Created by Finn Behrens on 31.03.22.
//

import Foundation

/// Gets information about all devices for the current user.
public struct MatrixDevicesRequest: MatrixRequest {
    public typealias Response = MatrixDevices

    public func components(for homeserver: MatrixHomeserver, with _: ()) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/devices")
    }

    public static var httpMethod: HttpMethod {
        .GET
    }

    public static var requiresAuth: Bool {
        true
    }
}

/// Gets information on a single device, by device id.
public struct MatrixDeviceRequest: MatrixRequest {
    public typealias Response = MatrixDevice

    public func components(for homeserver: MatrixHomeserver, with deviceID: String) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/devices/\(deviceID)")
    }

    public static var httpMethod: HttpMethod {
        .GET
    }

    public static var requiresAuth: Bool {
        true
    }
}

/// A list of all registered devices for this user.
public struct MatrixDevices: MatrixResponse {
    /// A list of all registered devices for this user.
    public var devices: [MatrixDevice]
}

/// A registered device for this user.
public struct MatrixDevice: MatrixResponse {
    /// Identifier of this device.
    public var deviceID: String

    /// Display name set by the user for this device. Absent if no name has been set.
    public var displayName: String?

    /// The IP address where this device was last seen. (May be a few minutes out of date, for efficiency reasons).
    public var lastSeenIP: String?

    /// The time this device was last seen.
    public var lastSeen: Date

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case displayName = "display_name"
        case lastSeenIP = "last_seen_ip"
        case lastSeen = "last_seen_ts"
    }
}

public struct MatrixSetDeviceDisplayName: MatrixRequest {
    public var displayName: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
    }

    public typealias Response = MatrixEmptyResponse

    public func components(for homeserver: MatrixHomeserver, with deviceID: String) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/devices/\(deviceID)")
    }

    public static var httpMethod: HttpMethod {
        .PUT
    }

    public static var requiresAuth: Bool {
        true
    }
}

public struct MatrixDeleteDeviceRequest: MatrixRequest {
    /// Additional authentication information for the user-interactive authentication API.
    public var auth: MatrixInteractiveAuthResponse?

    public typealias Response = MatrixDeleteDeviceContainer

    public func components(for homeserver: MatrixHomeserver, with deviceID: String) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/devices/\(deviceID)")
    }

    public static var httpMethod: HttpMethod {
        .DELETE
    }

    public static var requiresAuth: Bool {
        true
    }

    public func parse(data: Data, response: HTTPURLResponse) throws -> MatrixDeleteDeviceContainer {
        guard response.statusCode != 401 else {
            return try .interactive(.init(fromMatrixRequestData: data))
        }

        guard response.statusCode == 200 else {
            throw try MatrixServerError(json: data, code: response.statusCode)
        }

        return .success
    }
}

public struct MatrixDeleteDevicesRequest: MatrixRequest {
    /// Additional authentication information for the user-interactive authentication API.
    public var auth: MatrixInteractiveAuthResponse?

    /// The list of device IDs to delete.
    public var devices: [String]

    public typealias Response = MatrixDeleteDeviceContainer

    public func components(for homeserver: MatrixHomeserver, with _: ()) throws -> URLComponents {
        homeserver.path("/_matrix/client/v3/delete_devices")
    }

    public static var httpMethod: HttpMethod {
        .POST
    }

    public static var requiresAuth: Bool {
        true
    }

    public func parse(data: Data, response: HTTPURLResponse) throws -> MatrixDeleteDeviceContainer {
        guard response.statusCode != 401 else {
            return try .interactive(.init(fromMatrixRequestData: data))
        }

        guard response.statusCode == 200 else {
            throw try MatrixServerError(json: data, code: response.statusCode)
        }

        return .success
    }
}

public enum MatrixDeleteDeviceContainer: MatrixResponse {
    case success
    case interactive(MatrixInteractiveAuth)

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    public var interactiveData: MatrixInteractiveAuth? {
        switch self {
        case let .interactive(matrixInteractiveAuth):
            return matrixInteractiveAuth
        default:
            return nil
        }
    }
}
