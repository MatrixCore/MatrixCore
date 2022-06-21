//
//  File.swift
//
//
//  Created by Finn Behrens on 16.04.22.
//

import Foundation
import MatrixClient

let MXkSecAttrLabel: String = "dev.matrixcore.access_token"

public protocol MatrixStoreAccountInfo {
    associatedtype AccountIdentifier

    var id: AccountIdentifier { get }

    var name: String { get }
    var displayName: String? { get set }
    var mxID: MatrixFullUserIdentifier { get }
    var homeServer: MatrixHomeserver { get }
    var accessToken: String? { get set }
    
    var FQMXID: String { get }
    
    // Keychain functions
    func saveToKeychain(extraKeychainArguments: [String: Any]) throws
    static func getFromKeychain(account: MatrixFullUserIdentifier,
                                extraKeychainArguments: [String: Any]) throws -> String
    func deleteFromKeychain(extraKeychainArguments: [String: Any]) throws
    
    mutating func loadAccessToken(extraKeychainArguments: [String: Any]) throws
}

// TODO: only on Darwin platforms
public extension MatrixStoreAccountInfo {
    static func addDefaultInfo(_ dict: [String: Any], mxID: MatrixFullUserIdentifier) -> [String: Any] {
        var dict = dict
        dict[kSecClass as String] = kSecClassGenericPassword
        dict[kSecAttrAccount as String] = mxID.FQMXID
        //dict[kSecUseDataProtectionKeychain as String] = true
        if dict[kSecAttrLabel as String] == nil {
            dict[kSecAttrLabel as String] = MXkSecAttrLabel
        }
        
        return dict
    }
    
    /// Load the ``accessToken`` from Keychain.
    static func getFromKeychain(account: MatrixFullUserIdentifier,
                                extraKeychainArguments: [String: Any] = [:]) throws -> String
    {
        var keychainQuery = Self.addDefaultInfo(extraKeychainArguments, mxID: account)
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecReturnAttributes as String] = true
        keychainQuery[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }

        guard let existingItem = item as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            throw MatrixCoreError.keychainError(errSecInvalidData)
        }

        return token
    }

    /// Save the ``accessToken`` to keychain, using the accountID data as identifier.
    func saveToKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
        guard let accessToken = self.accessToken?.data(using: .utf8)
        else {
            throw MatrixErrorCode.NotFound
        }

        var keychainInsertQuery = Self.addDefaultInfo(extraKeychainArguments, mxID: mxID)
        keychainInsertQuery[kSecValueData as String] = accessToken

        let status = SecItemAdd(keychainInsertQuery as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw MatrixCoreError.keychainError(status)
        }
    }

    func deleteFromKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
        var keychainQuery = Self.addDefaultInfo(extraKeychainArguments, mxID: mxID)
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecReturnRef as String] = true
        keychainQuery[kSecReturnAttributes as String] = true

        
        /*var item: CFTypeRef?
        var status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
         */


        let status = SecItemDelete(keychainQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
    }
    
    internal var accessTokenTag: String {
        Self.accessTokenTag(forId: mxID)
    }
    
    internal static func accessTokenTag(forId: MatrixFullUserIdentifier) -> String {
        "dev.matrixcore.keychain.\(forId.FQMXID.replacingOccurrences(of: "@", with: ""))"
    }
    
    func getFromKeychain(extraKeychainArguments: [String: Any] = [:]) throws -> String {
        try Self.getFromKeychain(account: self.mxID, extraKeychainArguments: extraKeychainArguments)
    }
    
    mutating func loadAccessToken(extraKeychainArguments: [String: Any] = [:]) throws {
        try self.accessToken = self.getFromKeychain(extraKeychainArguments: extraKeychainArguments)
    }
}

@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public extension MatrixStore {
    /// Create ``MatrixCore`` instances from the account data saved in the store.
    @MainActor
    func getAccounts() async throws -> [MatrixCore<Self>] {
        let accounts = try await getAccountInfos()

        return accounts.map { MatrixCore(store: self, account: $0) }
        // Init MatrixCore.client somehow?
    }

    /// Create ``MatrixCore`` instance for the given MatrixUser ID with data from the store.
    @MainActor
    func getAccount(_ mxID: AccountInfo.AccountIdentifier) async throws -> MatrixCore<Self> {
        let account = try await getAccountInfo(accountID: mxID)

        return MatrixCore(store: self, account: account)
    }
}

public extension MatrixStoreAccountInfo {
    var FQMXID: String {
        mxID.FQMXID
    }
}

public extension MatrixStoreAccountInfo where Self.AccountIdentifier == MatrixFullUserIdentifier {
    var id: MatrixFullUserIdentifier {
        mxID
    }
}
