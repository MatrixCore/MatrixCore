//
//  File.swift
//
//
//  Created by Finn Behrens on 26.03.22.
//

import Foundation

public enum MatrixCoreError: Error {
    case actorMissing
    case missingData
    case creationError
    case batchInsertError
    case batchDeleteError
    case persistentHistoryChangeError
    case unexpectedError(error: Error)
    case keychainError(OSStatus)
}

extension MatrixCoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .actorMissing:
            return NSLocalizedString("Did not found MatrixCore instance to use for request", comment: "")
        case .missingData:
            return NSLocalizedString(
                "Found and will discard a quake missing a valid code, magnitude, place, or time.",
                comment: ""
            )
        case .creationError:
            return NSLocalizedString("Failed to create a new Quake object.", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Failed to execute a batch insert request.", comment: "")
        case .batchDeleteError:
            return NSLocalizedString("Failed to execute a batch delete request.", comment: "")
        case .persistentHistoryChangeError:
            return NSLocalizedString("Failed to execute a persistent history change request.", comment: "")
        case let .unexpectedError(error):
            return NSLocalizedString("Received unexpected error. \(error.localizedDescription)", comment: "")
        case let .keychainError(error):
            return NSLocalizedString("Keychain did not succedd. \(error)", comment: "")
        }
    }
}

extension MatrixCoreError: Identifiable {
    public var id: String? {
        errorDescription
    }
}
