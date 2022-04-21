//
//  File.swift
//
//
//  Created by Finn Behrens on 16.04.22.
//

import Foundation
import MatrixClient

public protocol MatrixStoreAccountInfo {
    associatedtype AccountIdentifier

    var id: AccountIdentifier { get }

    var name: String { get }
    var displayName: String? { get set }
    var mxID: MatrixFullUserIdentifier { get }
    var homeServer: MatrixHomeserver { get }
    var accessToken: String? { get set }
}

// TODO: only on Darwin platforms
public extension MatrixStoreAccountInfo {
    /// Load the ``accessToken`` from Keychain.
    static func getFromKeychain(account: MatrixFullUserIdentifier,
                                extraKeychainArguments: [String: Any] = [:]) throws -> String
    {
        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecAttrAccount as String] = account.FQMXID
        keychainQuery[kSecAttrServer as String] = account.domain
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
            throw MatrixError.NotFound
        }

        var keychainInsertQuery = extraKeychainArguments
        keychainInsertQuery[kSecClass as String] = kSecClassInternetPassword
        keychainInsertQuery[kSecAttrAccount as String] = mxID.FQMXID
        keychainInsertQuery[kSecAttrServer as String] = mxID.domain
        keychainInsertQuery[kSecValueData as String] = accessToken

        let status = SecItemAdd(keychainInsertQuery as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw MatrixCoreError.keychainError(status)
        }
    }

    func deleteFromKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecAttrAccount as String] = mxID.FQMXID
        keychainQuery[kSecAttrServer as String] = mxID.domain

        let status = SecItemDelete(keychainQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
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
