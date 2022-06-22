//
//  File.swift
//  
//
//  Created by Finn Behrens on 22.06.22.
//

import Foundation

@frozen
public struct MatrixContentURL: RawRepresentable, Equatable, Identifiable, Hashable, Codable {
    public init?(string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        self.rawValue = url
    }
    
    public init?(rawValue: URL) {
        self.rawValue = rawValue
    }
    
    public var rawValue: URL
    
    public var absoluteString: String {
        rawValue.absoluteString
    }
    
    public var host: String? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return rawValue.host()
        } else {
            return rawValue.host
        }
    }
    
    public var path: String? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return rawValue.path()
        } else {
            return rawValue.path
        }
    }
    
    public var mediaId: String? {
        path
    }
    
    public func downloadURL(allowRemote: Bool? = nil) -> URL? {
        guard let host,
              let path
        else {
            return nil
        }
        var components = URLComponents()
        components.host = host
        components.scheme = "https"
        components.path = "/_matrix/media/v3/download/" + host + path
        if let allowRemote {
            components.queryItems = [.init(name: "allow_remote", value: allowRemote.description)]
        }
        
        return components.url
    }
    
    public var id: URL {
        rawValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(URL.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    public enum CodingKeys: CodingKey {
        case rawValue
    }
}
