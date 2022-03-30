
import CoreData
import Foundation
import MatrixClient
import OSLog

@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
@MainActor
public class MatrixCore {
    public let context: NSManagedObjectContext

    internal let coreDataMatrixAccount: MatrixAccount

    public internal(set) var client: MatrixClient
    public internal(set) var userID: MatrixUserIdentifier

    internal static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MatrixCore")

    // MARK: - Dynamic variables

    public var displayName: String? {
        coreDataMatrixAccount.displayName
    }

    // MARK: - Init

    /// Create a MatrixCore from login response.
    public convenience init(
        homeserver: MatrixHomeserver,
        login: MatrixLogin,
        matrixStore: MatrixStore = MatrixStore.shared,
        save _: Bool = true
    ) async throws {
        guard let userID = login.userId,
              let FQMXID = userID.FQMXID,
              let accessToken = login.accessToken
        else {
            throw MatrixCoreError.missingData
        }

        let context = matrixStore.newTaskContext()
        context.name = "MatrixCore(\(FQMXID)"
        context.transactionAuthor = "MatrixCore"

        let client: MatrixClient

        if let wellKnown = login.wellKnown,
           let homeserverBaseURL = wellKnown.homeserver?.baseURL,
           let homeserver = MatrixHomeserver(string: homeserverBaseURL)
        {
            client = MatrixClient(
                homeserver: homeserver,
                urlSession: URLSession(configuration: .default),
                accessToken: accessToken
            )
        } else {
            client = MatrixClient(
                homeserver: homeserver,
                urlSession: URLSession(configuration: .default),
                accessToken: accessToken
            )
        }

        try await self.init(client: client, userID: userID, accessToken: accessToken, context: context)
    }

    /// Create a MatrixCore from register response.
    public convenience init(
        homeserver: MatrixHomeserver,
        register: MatrixRegister,
        matrixStore: MatrixStore = MatrixStore.shared,
        save _: Bool = true
    ) async throws {
        guard let FQMXID = register.userID.FQMXID
        else {
            throw MatrixCoreError.missingData
        }

        let context = matrixStore.newTaskContext()
        context.name = "MatrixCore(\(FQMXID)"
        context.transactionAuthor = "MatrixCore"

        let client: MatrixClient = .init(
            homeserver: homeserver,
            urlSession: URLSession(configuration: .default),
            accessToken: register.accessToken
        )

        try await self.init(
            client: client,
            userID: register.userID,
            accessToken: register.accessToken,
            context: context,
            save: true
        )
    }

    internal init(
        client: MatrixClient,
        userID: MatrixUserIdentifier,
        accessToken _: String,
        context: NSManagedObjectContext,
        save: Bool = true
    ) async throws {
        self.context = context

        self.userID = userID
        self.client = client

        coreDataMatrixAccount = MatrixAccount(context: self.context)
        coreDataMatrixAccount.homeserver = client.homeserverURL
        coreDataMatrixAccount.userID = userID.FQMXID!

        if save {
            try saveToKeychain()
            try self.save()
        }
    }

    internal init(fromCoreData account: MatrixAccount, matrixStore: MatrixStore) async throws {
        let context = matrixStore.newTaskContext()
        context.name = "MatrixCore(\(account.userID!)"
        context.transactionAuthor = "MatrixCore"
        self.context = context

        let account: MatrixAccount = await context.perform {
            context.object(with: account.objectID) as! MatrixAccount
        }
        coreDataMatrixAccount = account

        userID = account.mxUserId!
        let accessToken = try MatrixCore.loadFromKeychain(
            userID: userID.FQMXID!,
            domain: userID.domain!,
            extraKeychainArguments: MatrixCoreSettings.extraKeychainArguments
        )

        client = MatrixClient(
            homeserver: MatrixHomeserver(url: account.homeserver!)!,
            urlSession: URLSession(configuration: .default),
            accessToken: accessToken
        )
    }

    public static func loadFromCoreData(matrixStore: MatrixStore = MatrixStore.shared) async throws -> [MatrixCore] {
        let context = matrixStore.newTaskContext()
        context.name = "MatrixCore(loader)"
        context.transactionAuthor = "MatrixCore"

        return try await MatrixCore.loadFromCoreData(context: context, matrixStore: matrixStore)
    }

    public static func loadFromCoreData(context: NSManagedObjectContext,
                                        matrixStore: MatrixStore) async throws -> [MatrixCore]
    {
        let accounts = try await context.perform {
            try context.fetch(MatrixAccount.fetchRequest())
        }

        var ret: [MatrixCore] = []

        for account in accounts {
            do {
                try await ret.append(MatrixCore(fromCoreData: account, matrixStore: matrixStore))
            } catch {
                MatrixCore.logger.error("Failed to load account '\(account.userID!)': \(error.localizedDescription)")
            }
        }

        return ret
    }

    // MARK: - Account Persistence

    public func save() throws {
        try context.save()
    }

    /// Save accessToken to keychain.
    public func saveToKeychain(extraKeychainArguments: [String: Any] = MatrixCoreSettings
        .extraKeychainArguments) throws
    {
        let userID = self.userID.FQMXID!

        var keychainInsertquery = extraKeychainArguments
        keychainInsertquery[kSecClass as String] = kSecClassInternetPassword
        keychainInsertquery[kSecAttrAccount as String] = userID
        keychainInsertquery[kSecAttrServer as String] = self.userID.domain!
        keychainInsertquery[kSecValueData as String] = client.accessToken!.data(using: .utf8)

        let status = SecItemAdd(keychainInsertquery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
    }

    /// Load access token from keychain
    internal static func loadFromKeychain(userID: String, domain: String,
                                          extraKeychainArguments: [String: Any]) throws -> String
    {
        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
        keychainQuery[kSecAttrAccount as String] = userID
        keychainQuery[kSecAttrServer as String] = domain
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

    // MARK: - logout

    public func logout() async throws {
        try await client.logout()
        try await context.perform {
            self.context.delete(self.coreDataMatrixAccount)
            try self.context.save()
        }

        do {
            try deleteKeychain()
        } catch let MatrixCoreError.keychainError(osStatus) {
            MatrixCore.logger.error("Failed to delete Keychain item: \(osStatus)")
        } catch {
            throw error
        }
    }

    public func deleteKeychain() throws {
        try MatrixCore.deleteKeychain(
            userID: userID.FQMXID!,
            domain: userID.domain!,
            extraKeychainArguments: MatrixCoreSettings.extraKeychainArguments
        )
    }

    internal static func deleteKeychain(userID: String, domain: String,
                                        extraKeychainArguments: [String: Any]) throws
    {
        var keychainQuery = extraKeychainArguments
        keychainQuery[kSecClass as String] = kSecClassInternetPassword
        keychainQuery[kSecAttrAccount as String] = userID
        keychainQuery[kSecAttrServer as String] = domain

        let status = SecItemDelete(keychainQuery as CFDictionary)
        guard status == errSecSuccess else {
            throw MatrixCoreError.keychainError(status)
        }
    }

    // MARK: - ??

    public func updateDisplayName() async throws {
        let displayname = try await client.getDisplayName(userID)
        coreDataMatrixAccount.displayName = displayname
        try await context.perform {
            try self.context.save()
        }
    }
}

// MARK: - old - REMOVE

/*
 @available(swift, introduced: 5.5)
 @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
 public actor MatrixCore {
     public internal(set) var client: MatrixClient
     public internal(set) var userID: MatrixUserIdentifier

     // MARK: - Init

     // MARK: - computed variables

     public var accessToken: String? {
         client.accessToken
     }

     // MARK: keychain
     func saveToCoreData() async throws {
         let account = MatrixAccount(context: context)

         account.homeserver = self.client.homeserver.url.url!
         account.userID = userID.FQMXID!

         try await context.perform {
             try self.context.save()
         }

     }

     func saveToKeychain(extraKeychainArguments: [String: Any] = [:]) throws {
         guard let userID = self.userID.FQMXID else {
             throw MatrixCoreError.missingData
         }

         var keychainInsertquery = extraKeychainArguments
         keychainInsertquery[kSecClass as String] = kSecClassInternetPassword
         keychainInsertquery[kSecAttrAccount as String] = userID
         keychainInsertquery[kSecAttrServer as String] = self.userID.domain!
         keychainInsertquery[kSecValueData as String] = self.client.accessToken!.data(using: .utf8)

         let status = SecItemAdd(keychainInsertquery as CFDictionary, nil)
         guard status == errSecSuccess else {
             throw MatrixCoreError.keychainError(status)
         }
     }

     public convenience init(userID: MatrixUserIdentifier, extraKeychainArguments: [String: Any] = [:], homeserver: MatrixHomeserver?) async throws {
         let useHomeserver: MatrixHomeserver
         if let homeserver = homeserver {
             useHomeserver = homeserver
         } else {
             useHomeserver = try await MatrixHomeserver(resolve: "https://\(userID.domain!)")
         }

         var keychainQuery = extraKeychainArguments
         keychainQuery[kSecClass as String] = kSecClassInternetPassword
         keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
         keychainQuery[kSecAttrAccount as String] = userID.FQMXID!
         keychainQuery[kSecAttrServer as String] = userID.domain!
         keychainQuery[kSecReturnAttributes as String] = true
         keychainQuery[kSecReturnData as String] = true

         var item: CFTypeRef?
         let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
         guard status == errSecSuccess else {
             throw MatrixCoreError.keychainError(status)
         }

         guard let existingItem = item as? [String : Any],
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8)
         else {
             throw MatrixCoreError.keychainError(errSecInvalidData)
         }

         self.init(homeserver: useHomeserver, userID: userID, accessToken: password)
     }
 }
 */
