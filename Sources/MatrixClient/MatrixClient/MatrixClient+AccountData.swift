//
//  File.swift
//
//
//  Created by Finn Behrens on 26.03.22.
//

import Foundation

public extension MatrixClient {
    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func setAccountData<T: MatrixAccountData>(userID: MatrixUserIdentifier, roomID: String? = nil,
                                              _ data: T) async throws
    {
        _ = try await MatrixSetAccountData(content: data)
            .response(
                on: homeserver,
                withToken: accessToken,
                with: .init(userID: userID, roomID: roomID),
                withUrlSession: urlSession
            )
    }

    @available(swift, introduced: 5.5)
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func getAccountData<T: MatrixAccountData>(userID: MatrixUserIdentifier, roomID: String? = nil) async throws -> T {
        try await MatrixGetAccountData()
            .response(
                on: homeserver,
                withToken: accessToken,
                with: .init(userID: userID, roomID: roomID),
                withUrlSession: urlSession
            )
    }
}
