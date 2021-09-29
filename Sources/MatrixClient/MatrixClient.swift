//
//  MatrixClient.swift
//  File
//
//  Created by Finn Behrens on 27.09.21.
//

import Foundation

public struct MatrixClient {
    public var homeserver: MatrixHomeserver
    public var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    /// Access token used to authorize api requests
    public var accessToken: String?
    
    // 2.1 GET /_maftrix/client/versions
    /// Gets the versions of the specification supported by the server.
    ///
    /// Values will take the form `rX.Y.Z`.
    ///
    /// Only the latest `Z` value will be reported for each supported `X.Y` value. i.e. if the server implements `r0.0.0`, `r0.0.1`, and
    /// `r1.2.0`, it will report `r0.0.1` and `r1.2.0`.
    ///
    /// The server may additionally advertise experimental features it supports through unstable_features. These features should be namespaced
    /// and may optionally include version information within their name if desired. Features listed here are not for optionally toggling parts of the
    /// Matrix specification and should only be used to advertise support for a feature which has not yet landed in the spec. For example, a feature
    /// currently undergoing the proposal process may appear here and eventually be taken off this list once the feature lands in the spec and the
    /// server deems it reasonable to do so. Servers may wish to keep advertising features here after they've been released into the spec to give
    /// clients a chance to upgrade appropriately. Additionally, clients should avoid using unstable features in their stable releases.
    ///
    /// ```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   No.
    /// ```
    public func getVersions() async throws -> MatrixServerInfo {
        return try await MatrixServerInfoRequest().repsonse(on: homeserver, with: (), withUrlSession: urlSession)
    }
    
    /// Gets discovery information about the domain. The file may include additional keys, which MUST follow the Java package naming convention,
    /// e.g. `com.example.myapp.property`. This ensures property names are suitably namespaced for each application and reduces the risk of clashes.
    ///
    /// Note that this endpoint is not necessarily handled by the homeserver, but by another webserver, to be used for discovering the homeserver URL.
    ///
    ///```markdown
    ///    Rate-limited:    No.
    ///    Requires auth:   No.
    ///```
    public func getWellKnown() async throws -> MatrixWellKnown {
        return try await MatrixWellKnownRequest().repsonse(on: homeserver, with: (), withUrlSession: urlSession)
    }
    
    /// Gets the homeserver's supported login types to authenticate users. Clients should pick one of these and supply it as the type when logging in.
    ///
    /// ```markdown
    ///    Rate-limited:    Yes.
    ///    Requires auth:   No.
    /// ```
    public func getLoginFlows() async throws -> [MatrixLoginFlow] {
        let flows = try await MatrixLoginFlowRequest().repsonse(on: homeserver, with: (), withUrlSession: urlSession)
        
        return flows.flows.map({$0.type})
    }
}


