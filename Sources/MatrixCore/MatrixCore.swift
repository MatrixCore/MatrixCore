
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

    public init?(homeserver: MatrixHomeserver, loginResponse login: MatrixLogin) {
        guard let userID = login.userId else {
            return nil
        }

        let newHomeserver: MatrixHomeserver
        if let baseURL = login.wellKnown?.homeserver?.baseURL {
            newHomeserver = MatrixHomeserver(string: baseURL)!
        } else {
            newHomeserver = homeserver
        }

        self.userID = userID
        client = MatrixClient(
            homeserver: newHomeserver,
            urlSession: URLSession(configuration: .default),
            accessToken: login.accessToken
        )
    }

    public init(homeserver: MatrixHomeserver, userID: MatrixUserIdentifier, accessToken: String) {
        client = MatrixClient(
            homeserver: homeserver,
            urlSession: URLSession(configuration: .default),
            accessToken: accessToken
        )
        self.userID = userID
    }

    // MARK: - computed variables

    public var accessToken: String? {
        client.accessToken
    }
}
