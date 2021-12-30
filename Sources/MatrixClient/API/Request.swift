//
//  File.swift
//  File
//
//  Created by Finn Behrens on 29.09.21.
//

import Foundation

public enum HttpMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    
    static var containsBody: [Self] = [ .POST, .PUT, .PATCH ]
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
    func request(on homeserver: MatrixHomeserver, withToken token: String? = nil, with parameters: URLParameters) throws -> URLRequest {
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
    
    @available(swift, introduced: 5.5)
    func response(on homeserver: MatrixHomeserver, withToken token: String? = nil, with parameters: URLParameters, withUrlSession urlSession: URLSession = URLSession.shared) async throws -> Response {
        let request = try request(on: homeserver, withToken: token, with: parameters)
        
        let (data, urlResponse) = try await urlSession.data(for: request)
        
        guard let response = urlResponse as? HTTPURLResponse else {
            throw MatrixError.Unknown
        }
        guard response.statusCode == 200 else {
            throw try MatrixServerError(json: data, code: response.statusCode)
        }
        
        return try Response(fromMatrixRequestData: data)
    }
}

/// Protocol for a Matrix server response
public protocol MatrixResponse: Codable {
}

public extension MatrixResponse {
    init(fromMatrixRequestData data: Data) throws {
        let decoder = JSONDecoder()
        decoder.userInfo[.matrixEventTypes] = MatrixClient.eventTypes
        self = try decoder.decode(Self.self, from: data)
    }
}

