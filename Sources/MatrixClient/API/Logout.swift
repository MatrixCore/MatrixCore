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
    
    public func path(with all: Bool) -> String {
        if all {
            return "/_matrix/client/r0/logout/all"
        } else {
            return "/_matrix/client/r0/logout"
        }
    }
    
    public static var httpMethod = HttpMethod.POST
    
    public static var requiresAuth = true
}

public struct MatrixLogout: MatrixResponse {
    
}
