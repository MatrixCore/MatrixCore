//
//  MatrixClient+Auth.swift
//
//
//  Created by Finn Behrens on 04.03.22.
//

import Foundation

public extension MatrixClient {
    // MARK: - Login Flows

    /// Gets the homeserver's supported login types to authenticate users. Clients should pick one of these and supply it as the type when logging in.
    ///
    /// ```markdown
    ///    Rate-limited:    Yes.
    ///    Requires auth:   No.
    /// ```
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getLoginFlows() async throws -> [MatrixLoginFlow] {
        try await MatrixLoginFlowRequest()
            .response(on: homeserver, withToken: accessToken, with: (), withUrlSession: urlSession)
            .flows.map(\.type)
    }

    /// Test if the server supports password authentication.
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func supportsPasswordAuth() async throws -> Bool {
        let flows = try await getLoginFlows()
        return flows.contains(where: { $0 == MatrixLoginFlow.password })
    }

    // MARK: - Register

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getRegisterFlows(kind: MatrixRegisterRequest.RegisterKind = .user) async throws -> MatrixInteractiveAuth {
        let resp = try await MatrixRegisterRequest(password: "")
            .response(on: homeserver, with: kind, withUrlSession: urlSession)

        switch resp {
        case let .interactive(flows):
            return flows
        default:
            throw MatrixError.NotFound
        }
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func canRegister() async throws -> Bool {
        do {
            _ = try await getRegisterFlows()
        } catch let error as MatrixServerError {
            if error.errcode == .Forbidden {
                return false
            }
            throw error
        } catch {
            throw error
        }
        return true
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func register(
        password: String,
        username: String? = nil,
        auth: MatrixInteractiveAuthResponse? = nil,
        bind_email: Bool? = nil,
        kind: MatrixRegisterRequest.RegisterKind = .user
    ) async throws -> MatrixRegisterContainer {
        try await MatrixRegisterRequest(
            username: username,
            bindEmail: bind_email,
            password: password,
            auth: auth
        )
        .response(on: homeserver, with: kind, withUrlSession: urlSession)
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func requestEmailToken(
        clientSecret: String,
        email: String,
        sendAttempt: Int = 0
    ) async throws -> MatrixRegisterRequestEmailToken {
        try await MatrixRegisterRequestEmailTokenRequest(
            clientSecret: clientSecret,
            email: email,
            sendAttempt: sendAttempt
        )
        .response(on: homeserver, with: (), withUrlSession: urlSession)
    }

    // MARK: - Login

    /// Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.
    ///
    /// If the client does not supply a device_id, the server must auto-generate one.
    ///
    /// The returned access token must be associated with the device_id supplied by the client or generated by the server. The server may invalidate
    /// any access token previously associated with that device. See [Relationship between access tokens and devices](https://matrix.org/docs/spec/client_server/latest#relationship-between-access-tokens-and-devices).
    ///
    /// ```markdown
    ///    Rate-limited:    Yes.
    ///    Requires auth:   No.
    /// ```
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func login(
        token: Bool = false,
        username: String,
        password: String,
        displayName: String? = nil,
        deviceId: String? = nil
    ) async throws -> MatrixLogin {
        let flow: MatrixLoginFlow
        if token {
            flow = .token
        } else {
            flow = .password
        }
        var request = MatrixLoginRequest(
            type: flow.rawValue,
            identifier: MatrixLoginUserIdentifier.user(id: username),
            deviceId: deviceId,
            initialDeviceDisplayName: displayName
        )
        if token {
            request.token = password
        } else {
            request.password = password
        }

        return try await login(request: request)
    }

    /// Authenticates the user, and issues an access token they can use to authorize themself in subsequent requests.
    ///
    /// If the client does not supply a device_id, the server must auto-generate one.
    ///
    /// The returned access token must be associated with the device_id supplied by the client or generated by the server. The server may invalidate
    /// any access token previously associated with that device. See [Relationship between access tokens and devices](https://matrix.org/docs/spec/client_server/latest#relationship-between-access-tokens-and-devices).
    ///
    /// ```markdown
    ///    Rate-limited:    Yes.
    ///    Requires auth:   No.
    /// ```
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func login(request: MatrixLoginRequest) async throws -> MatrixLogin {
        try await request
            .response(on: homeserver, withToken: accessToken, with: (), withUrlSession: urlSession)
    }

    // MARK: - Logout

    // 5.5.3 POST /_matrix/client/r0/logout
    /// Logout the access token.
    ///
    /// Invalidates an existing access token, so that it can no longer be used for authorization. The device associated with the
    /// access token is also deleted. [Device keys](https://matrix.org/docs/spec/client_server/latest#device-keys) for the device
    /// are deleted alongside the device.
    ///
    ///
    /// ```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    /// ```
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func logout(all: Bool = false) async throws {
        _ = try await MatrixLogoutRequest()
            .response(on: homeserver, withToken: accessToken, with: all, withUrlSession: urlSession)
    }

    /// Logout the access token.
    ///
    /// Invalidates an existing access token, so that it can no longer be used for authorization. The device associated with the
    /// access token is also deleted. [Device keys](https://matrix.org/docs/spec/client_server/latest#device-keys) for the device
    /// are deleted alongside the device.
    ///
    ///
    /// ```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    /// ```
    @available(swift, deprecated: 5.5, renamed: "logout(all:)")
    func logout(all: Bool = false,
                callback: @escaping ((Result<MatrixLogout, Error>) -> Void)) throws -> URLSessionDataTask
    {
        try MatrixLogoutRequest()
            .response(on: homeserver, withToken: accessToken, with: all, withUrlSession: urlSession, callback: callback)
    }

    /// Logout all tokens.
    ///
    /// Invalidates all access tokens for a user, so that they can no longer be used for authorization. This includes the access token that made this request.
    /// All devices for the user are also deleted. [Device keys](https://matrix.org/docs/spec/client_server/latest#device-keys) for
    /// the device are deleted alongside the device.
    ///
    /// This endpoint does not require UI authorization because UI authorization is designed to protect against attacks where the someone gets hold of a
    /// single access token then takes over the account. This endpoint invalidates all access tokens for the user, including the token used in the request,
    /// and therefore the attacker is unable to take over the account in this way.
    ///
    /// ```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    /// ```
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func logoutAll() async throws {
        try await logout(all: true)
    }
}
