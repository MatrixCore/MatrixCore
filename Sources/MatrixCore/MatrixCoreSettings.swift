//
//  File.swift
//
//
//  Created by Finn Behrens on 30.03.22.
//

import Foundation

public struct MatrixCoreSettings {
    /// Default keychain arguments, used when calling saveToKeychain or init with save = true (the default).
    public static var extraKeychainArguments: [String: Any] = [:]
}
