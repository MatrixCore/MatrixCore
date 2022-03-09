//
//  Register.swift
//
//
//  Created by Finn Behrens on 04.03.22.
//

import Foundation

public struct MatrixRegisterRequest {
    /// The local part of the desired Matrix ID. If omitted, the homeserver MUST generate a Matrix ID local part.
    public var username: String?

    /// If true, the server binds the email used for authentication to the Matrix ID with the ID Server.
    public var bindEmail: Bool?

    /// The desired password for the account.
    public var password: String

    /// Interactive flow response
    public var auth: MatrixInteractiveAuthResponse?

    enum CodingKeys: String, CodingKey {
        case username
        case bindEmail = "bind_email"
        case password
        case auth
    }
}

public extension MatrixRegisterRequest {
    enum RegisterKind: String, Codable {
        case guest
        case user
    }
}

extension MatrixRegisterRequest: MatrixRequest {
    public func components(for homeserver: MatrixHomeserver, with kind: RegisterKind) throws -> URLComponents {
        var components = homeserver.url

        components.path = "/_matrix/client/v3/register"
        components.queryItems = [.init(name: "kind", value: kind.rawValue)]
        return components
    }

    public static var httpMethod: HttpMethod {
        .POST
    }

    public static var requiresAuth: Bool {
        false
    }

    public typealias Response = MatrixRegisterContainer

    /// The kind of account to register. Defaults to user.
    public typealias URLParameters = MatrixRegisterRequest.RegisterKind

    @available(swift, introduced: 5.5)
    func response(on homeserver: MatrixHomeserver, withToken token: String? = nil, with parameters: URLParameters, withUrlSession urlSession: URLSession = URLSession.shared) async throws -> Response {
        let request = try request(on: homeserver, withToken: token, with: parameters)

        let (data, urlResponse) = try await urlSession.data(for: request)

        guard let response = urlResponse as? HTTPURLResponse else {
            throw MatrixError.Unknown
        }

        guard response.statusCode != 401 else {
            return try MatrixRegisterContainer.interactive(.init(fromMatrixRequestData: data))
        }

        guard response.statusCode == 200 else {
            throw try MatrixServerError(json: data, code: response.statusCode)
        }

        return try MatrixRegisterContainer.success(.init(fromMatrixRequestData: data))
    }
}

public struct MatrixRegister: MatrixResponse {
    /// An access token for the account. This access token can then be used to authorize other requests.
    /// The access token may expire at some point, and if so, it SHOULD come with a refresh_token.
    /// There is no specific error message to indicate that a request has failed because an access token has
    /// expired; instead, if a client has reason to believe its access token is valid, and it receives an auth error,
    /// they should attempt to refresh for a new token on failure, and retry the request with the new token.
    public var accessToken: String

    /// The hostname of the homeserver on which the account has been registered.
    public var homeServer: String

    /// A refresh_token may be exchanged for a new access_token using the /tokenrefresh API endpoint.
    public var refreshToken: String?

    /// The fully-qualified Matrix ID that has been registered.
    public var userID: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case homeServer = "home_server"
        case refreshToken = "refresh_token"
        case userID = "user_id"
    }
}

public enum MatrixRegisterContainer: MatrixResponse {
    case success(MatrixRegister)
    case interactive(MatrixInteractiveAuth)
}
