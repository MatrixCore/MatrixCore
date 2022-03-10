//
//  File.swift
//  File
//
//  Created by Finn Behrens on 29.09.21.
//

import Foundation

public enum HttpMethod: String, CaseIterable {
    case GET
    case POST
    case PUT
    case PATCH

    static var containsBody: [Self] = [.POST, .PUT, .PATCH]
}

public protocol MatrixRequest: Codable {
    associatedtype Response: MatrixResponse

    associatedtype URLParameters
    func components(for homeserver: MatrixHomeserver, with parameters: URLParameters) throws -> URLComponents

    static var httpMethod: HttpMethod { get }
    static var requiresAuth: Bool { get }
    // TODO: rate limited property?
}

public extension MatrixRequest {
    func request(on homeserver: MatrixHomeserver, withToken token: String? = nil,
                 with parameters: URLParameters) throws -> URLRequest
    {
        let components = try components(for: homeserver, with: parameters)
        // components.queryItems = self.queryParameters

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

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func download(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared
    ) async throws -> (Data, HTTPURLResponse) {
        let request = try request(on: homeserver, withToken: token, with: parameters)

        let (data, urlResponse) = try await urlSession.data(for: request)

        guard let response = urlResponse as? HTTPURLResponse else {
            throw MatrixError.Unknown
        }

        return (data, response)
    }

    @available(swift, deprecated: 5.5)
    func download(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared,
        callback: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)
    ) throws -> URLSessionDataTask {
        let request = try request(on: homeserver, withToken: token, with: parameters)

        return urlSession.dataTask(with: request) { data, response, error in
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

    @available(swift, deprecated: 5.5)
    @available(macOS, deprecated: 12.0)
    func response(
        on homeserver: MatrixHomeserver,
        withToken token: String? = nil,
        with parameters: URLParameters,
        withUrlSession urlSession: URLSession = URLSession.shared,
        callback: @escaping ((Result<Response, Error>) -> Void)
    ) throws -> URLSessionDataTask {
        return try download(on: homeserver, withToken: token, with: parameters, withUrlSession: urlSession) { resp in
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

/// Protocol for a Matrix server response
public protocol MatrixResponse: Codable {}

public extension MatrixResponse {
    init(fromMatrixRequestData data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.userInfo[.matrixEventTypes] = MatrixClient.eventTypes
        self = try decoder.decode(Self.self, from: data)
    }
}
