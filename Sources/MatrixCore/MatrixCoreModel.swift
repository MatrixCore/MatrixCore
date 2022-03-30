//
//  File.swift
//
//
//  Created by Finn Behrens on 26.03.22.
//

import Foundation
import MatrixClient

extension MatrixAccount {
    var mxUserId: MatrixUserIdentifier? {
        get {
            if let userID = userID {
                return .init(rawValue: userID)
            }
            return nil
        }
        set {
            userID = newValue?.FQMXID
        }
    }
}
