//
//  File.swift
//
//
//  Created by Finn Behrens on 30.03.22.
//

import Foundation

public extension MatrixAccount {
    var wrappedDisplayName: String {
        get { displayName ?? "" }
        set { displayName = newValue }
    }
}
