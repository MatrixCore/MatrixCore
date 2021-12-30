//
//  File.swift
//  File
//
//  Created by Finn Behrens on 30.09.21.
//

import Foundation

public struct MatrixLogoutRequest: MatrixRequest {
    public typealias Response = MatrixLogout
    
    public typealias URLParameters = Bool
    
    public func components(for homeserver: MatrixHomeserver, with all: Bool) -> URLComponents {
        var components = homeserver.url
        
        if all {
            components.path = "/_matrix/client/r0/logout/all"
        } else {
            components.path = "/_matrix/client/r0/logout"
        }
        
        return components
    }
    
    public static var httpMethod = HttpMethod.POST
    
    public static var requiresAuth = true
}

public struct MatrixLogout: MatrixResponse {
    
}
