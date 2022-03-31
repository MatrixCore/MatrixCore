//
//  File.swift
//
//
//  Created by Finn Behrens on 31.03.22.
//

import Foundation

public extension MatrixClient {
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getDevices() async throws -> MatrixDevices {
        try await MatrixDevicesRequest()
            .response(on: homeserver, withToken: accessToken, with: (), withUrlSession: urlSession)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    /// Gets information on a single device, by device id.
    func getDevice(_ deviceID: String) async throws -> MatrixDevice {
        try await MatrixDeviceRequest()
            .response(on: homeserver, withToken: accessToken, with: deviceID, withUrlSession: urlSession)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func setDeviceDisplayName(_ displayName: String, deviceID: String) async throws {
        _ = try await MatrixSetDeviceDisplayName(displayName: displayName)
            .response(on: homeserver, withToken: accessToken, with: deviceID, withUrlSession: urlSession)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func deleteDevices(devices: [String],
                       auth: MatrixInteractiveAuthResponse? = nil) async throws -> MatrixDeleteDeviceContainer
    {
        try await MatrixDeleteDevicesRequest(auth: auth, devices: devices)
            .response(on: homeserver, withToken: accessToken, with: (), withUrlSession: urlSession)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func deleteDevice(deviceID: String,
                      auth: MatrixInteractiveAuthResponse? = nil) async throws -> MatrixDeleteDeviceContainer
    {
        try await MatrixDeleteDeviceRequest(auth: auth)
            .response(on: homeserver, withToken: accessToken, with: deviceID, withUrlSession: urlSession)
    }
}
