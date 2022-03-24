
import Foundation
import MatrixClient

@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public actor MatrixCore {
    public internal(set) var client: MatrixClient
    public internal(set) var userID: MatrixUserIdentifier

    // MARK: - Init

    public init(homeserver: MatrixHomeserver, registerResponse register: MatrixRegister) {
        userID = register.userID
        client = MatrixClient(
            homeserver: homeserver,
            urlSession: URLSession(configuration: .default),
            accessToken: register.accessToken
        )
    }

    // MARK: - computed variables

    public var accessToken: String? {
        client.accessToken
    }
}
