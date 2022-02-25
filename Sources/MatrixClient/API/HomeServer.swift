//
//  HomeServer.swift
//  File
//
//  Created by Finn Behrens on 27.09.21.
//

import Foundation
import AnyCodable

public struct MatrixHomeserver: Codable {
    public var url: URLComponents
    
    public init?(string: String) {
        guard
            let components = URLComponents(string: string),
            components.host != nil
        else {
            return nil
        }
        
        self.url = components
    }
    
    @available(swift, introduced: 5.5)
    public init(resolve string: String, withUrlSession urlSession: URLSession = URLSession.shared) async throws {
        guard let self = MatrixHomeserver(string: string) else {
            throw MatrixError.NotFound
        }
        
        var res: MatrixWellKnown
        do {
            res = try await MatrixWellKnownRequest().response(on: self, with: (), withUrlSession: urlSession)
        } catch is MatrixServerError {
            url = self.url
            return
        }
        
        if let home_url = res.matrixHomeServer?.url {
            url = home_url
        } else {
            url = self.url
        }
    }
    
    
    public func path(_ path: String) -> URLComponents {
        var components = url
        components.path = path
        return components;
    }
}

public struct MatrixServerInfoRequest: MatrixRequest {
    public typealias Response = MatrixServerInfo
    
    public typealias URLParameters = ()
    
    public func components(for homeserver: MatrixHomeserver, with parameters: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/versions"
        return components
    }
    
    public static var httpMethod = HttpMethod.GET
    
    public static var requiresAuth = false
}

public struct MatrixServerInfo: MatrixResponse {
    /// The supported versions.
    public var versions: [String]
    
    /// Experimental features the server supports. Features not listed here, or the lack of this
    /// property all together, indicate that a feature is not supported.
    public var unstableFeatures: [String: Bool]?
    
    enum CodingKeys: String, CodingKey {
        case versions
        case unstableFeatures = "unstable_features"
    }
}

public struct MatrixWellKnownRequest: MatrixRequest {
    public typealias Response = MatrixWellKnown
    
    public typealias URLParameters = ()
    
    public func components(for homeserver: MatrixHomeserver, with parameters: ()) -> URLComponents {
        var components = homeserver.url
        components.path = "/.well-known/matrix/client"
        return components
    }
    
    public static var httpMethod = HttpMethod.GET
    
    public static var requiresAuth = false
}

public struct MatrixWellKnown: MatrixResponse {
    /// Used by clients to discover homeserver information.
    public var homeserver: ServerInformation?
    
    /// Used by clients to discover identity server information.
    public var identityServer: ServerInformation?
    
    // MARK: - dynamic variables
    /// The base URL for the homeserver for client-server connections.
    public var homeServerBaseUrl: String? {
        homeserver?.baseURL
    }
    
    public var matrixHomeServer: MatrixHomeserver? {
        guard let url = homeServerBaseUrl else {
            return nil
        }
        return MatrixHomeserver(string: url)
    }
    
    /// The base URL for the homeserver for client-server connections.
    public var identityServerBaseUrl: String? {
        identityServer?.baseURL
    }
    
    public var extraInfo: [String: AnyCodable]
    
    public struct ServerInformation: Codable {
        /// Base url of the server
        public var baseURL: String
        
        enum CodingKeys: String, CodingKey {
            case baseURL = "base_url"
        }
    }
}

extension MatrixWellKnown: Codable {
    private enum KnownCodingKeys: String, CodingKey, CaseIterable {
        case homeserver = "m.homeserver"
        case identityServer = "m.identity_server"
        
        static func doesNotContain(_ key: DynamicCodingKeys) -> Bool {
            !Self.allCases.map(\.stringValue).contains(key.stringValue)
        }
    }
    
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        // not used here, but a protocol requirement
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        self.homeserver = try container.decodeIfPresent(ServerInformation.self, forKey: .homeserver)
        self.identityServer = try container.decodeIfPresent(ServerInformation.self, forKey: .identityServer)
        
        self.extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(AnyCodable.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            self.extraInfo[key.stringValue] = decoded
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encodeIfPresent(self.homeserver, forKey: .homeserver)
        try container.encodeIfPresent(self.identityServer, forKey: .identityServer)
        
        var extraContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (name, value) in self.extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}
