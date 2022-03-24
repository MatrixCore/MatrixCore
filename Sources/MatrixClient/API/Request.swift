//
//  File.swift
//  File
//
//  Created by Finn Behrens on 29.09.21.
//

import Foundation

/// HTTP method to be used by ``MatrixClient/MatrixRequest``.
public enum HttpMethod: String, CaseIterable {
    case GET
    case POST
    case PUT
    case PATCH

    /// Methods which contain a body to parse.
    public static var containsBody: [Self] = [.POST, .PUT, .PATCH]
}

/// A type that can be requested on a Matrix server.
public protocol MatrixRequest: Codable {
    /// The type of response the Matrix server answers with on success.
    associatedtype Response: MatrixResponse

    /// Type used as an extra parameter to create the request.
    associatedtype URLParameters

    /// Function to create the URL to request, based on ``URLParameters``.
    func components(for homeserver: MatrixHomeserver, with parameters: URLParameters) throws -> URLComponents

    /// The ``MatrixClient/HttpMethod`` used by this request.
    static var httpMethod: HttpMethod { get }

    /// `True` if the request requires authentication.
    static var requiresAuth: Bool { get }

    func parse(data: Data, response: HTTPURLResponse) throws -> Response

    // TODO: rate limited property?
}

public extension MatrixRequest {
    /// Create the `URLRequest` to get the response data for this ``MatrixClient/MatrixRequest``.
    func request(on homeserver: MatrixHomeserver, withToken token: String? = nil,
                 with parameters: URLParameters) throws -> URLRequest
    {
        let components = try components(for: homeserver, with: parameters)

        var urlRequest = URLRequest(url: components.url!)

        if Self.requiresAuth {
            guard let token = token else {
                throw MatrixError.Forbidden
            }
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpMethod = Self.httpMethod.rawValue
        if HttpMethod.containsBody.contains(Self.httpMethod) {
            urlRequest.httpBody = try? JSONEncoder().encode(self)
        }

        return urlRequest
    }

    /// Checks for the http status code, and parses the data into ``Response``.
    func parse(data: Data, response: HTTPURLResponse) throws -> Response {
        guard response.statusCode == 200 else {
            throw try MatrixServerError(json: data, code: response.statusCode)
        }

        return try Response(fromMatrixRequestData: data)
    }

    /// Download the request data from the ``MatrixHomeserver``.
    ///
    /// The request to download the data is built via ``MatrixClient/MatrixRequest/request(on:withToken:with:)``.
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func download(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared
    ) async throws -> (Data, HTTPURLResponse) {
        let request = try request(on: homeserver, withToken: token, with: parameters)

        return try await download(request: request, withUrlSession: urlSession)
    }

    /// Download the given request.
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    @inlinable
    func download(
        request: URLRequest,
        withUrlSession urlSession: URLSession = URLSession.shared
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await urlSession.data(for: request)

        guard let response = urlResponse as? HTTPURLResponse else {
            throw MatrixError.Unknown
        }

        return (data, response)
    }

    /// Download the request data from the ``MatrixHomeserver``.
    ///
    /// The request to download the data is built via ``MatrixClient/MatrixRequest/request(on:withToken:with:)``.
    @available(swift, deprecated: 5.5, renamed: "download(on:withToken:with:withUrlSession:)")
    func download(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared,
        callback: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)
    ) throws -> URLSessionDataTask {
        let request = try request(on: homeserver, withToken: token, with: parameters)

        return download(request: request, withUrlSession: urlSession, callback: callback)
    }

    /// Download the given request.
    @available(swift, deprecated: 5.5, renamed: "download(request:withUrlSession:)")
    @inlinable
    func download(
        request: URLRequest,
        withUrlSession urlSession: URLSession = URLSession.shared,
        callback: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)
    ) -> URLSessionDataTask {
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  let data = data
            else {
                callback(.failure(MatrixError.Unknown))
                return
            }

            callback(.success((data, response)))
        }
    }

    /// Execute the ``MatrixRequest`` returning the ``MatrixRequest/Response``.
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func response(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared
    ) async throws -> Response {
        let (data, response) = try await download(on: homeserver, withToken: token, with: parameters,
                                                  withUrlSession: urlSession)

        return try parse(data: data, response: response)
    }

    /// Execute the ``MatrixRequest`` returning the ``MatrixRequest/Response``.
    @available(swift, deprecated: 5.5, renamed: "response(on:withToken:with:withUrlSession:)")
    @available(macOS, deprecated: 12.0)
    func response(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared,
        callback: @escaping ((Result<Response, Error>) -> Void)
    ) throws -> URLSessionDataTask {
        try download(on: homeserver, withToken: token, with: parameters, withUrlSession: urlSession) { resp in
            switch resp {
            case let .success((data, response)):
                do {
                    let data = try parse(data: data, response: response)
                    callback(.success(data))
                } catch {
                    callback(.failure(error))
                    return
                }
            case let .failure(e):
                callback(.failure(e))
            }
        }
    }
}

public protocol MatrixResponse: Codable {}

public extension MatrixResponse {
    /// Parse the json data into the ``MatrixResponse`` type.
    ///
    /// The ``MatrixRequest/parse(data:response:)`` function uses this, as this configures
    /// the `JSONDecoder` to use the correct types.
    ///
    /// - Parameter fromMatrixRequestData:
    init(fromMatrixRequestData data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.userInfo[.matrixEventTypes] = MatrixClient.eventTypes
        self = try decoder.decode(Self.self, from: data)
    }
}

public extension MatrixClient {
    static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }
}
