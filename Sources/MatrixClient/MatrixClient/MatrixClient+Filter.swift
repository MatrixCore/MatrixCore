//
//  MatrixClient+Filter.swift
//
//
//  Created by Finn Behrens on 04.03.22.
//

import Foundation

extension MatrixClient {
    // MARK: - set filter
    /// Uploads a new filter definition to the homeserver. Returns a filter ID that may be used in future requests to restrict which events are returned to the client.
    ///
    ///```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    ///```
    @available(swift, introduced: 5.5)
    public func setFilter(userId: String, filter: MatrixFilter) async throws -> MatrixFilterId {
        var id = try await filter
            .response(on: homeserver, withToken: accessToken, with: userId, withUrlSession: urlSession)

        id.user = userId
        return id
    }

    // MARK: - get filter
    /// Download a filter
    ///
    ///```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    ///```
    @available(swift, introduced: 5.5)
    @inlinable
    public func getFilter(userId: String, filterId: String) async throws -> MatrixFilter {
        try await getFilter(with: MatrixFilterId(user: userId, filter: filterId))
    }

    /// Download a filter
    ///
    ///```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   Yes.
    ///```
    @available(swift, introduced: 5.5)
    public func getFilter(with id: MatrixFilterId) async throws -> MatrixFilter {
        try await MatrixFilterRequest()
            .response(on: homeserver, withToken: accessToken, with: id, withUrlSession: urlSession)
    }
}
