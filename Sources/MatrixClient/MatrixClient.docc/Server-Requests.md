# Server Requests/Responses

@Metadata {
    @TechnologyRoot
}
@Comment {
    Somehow sub-sub-topics are not rendered. Ignoring for now
}

Making a Request/Response to a `Matrix` server.

## Overview

Requests and Responses where the ``MatrixClient/MatrixHomeserver`` takes part in are done via the
Protocols ``MatrixClient/MatrixRequest`` and ``MatrixClient/MatrixResponse``


## Topics

### Homeserver
- ``MatrixClient/MatrixHomeserver``

### Protocols

- ``MatrixClient/MatrixRequest``
- ``MatrixClient/MatrixResponse``

### Auth
- ``MatrixClient/MatrixLoginRequest``
- ``MatrixClient/MatrixLogin``
- ``MatrixClient/MatrixLogoutRequest``
- ``MatrixClient/MatrixLogout``

#### Register
- ``MatrixClient/MatrixRegisterRequest``
- ``MatrixClient/MatrixRegisterContainer``
- ``MatrixClient/MatrixRegister``
- ``MatrixClient/MatrixRegisterRequestEmailTokenRequest``
- ``MatrixClient/MatrixRegisterRequestEmailToken``

### Requests
- ``MatrixClient/MatrixLoginRequest``
- ``MatrixClient/MatrixFilterRequest``
- ``MatrixClient/MatrixLoginFlowRequest``
- ``MatrixClient/MatrixServerInfo``
- ``MatrixClient/MatrixSyncRequest``

### Responses
- ``MatrixClient/MatrixLogin``
- ``MatrixClient/MatrixFilter``
- ``MatrixClient/MatrixInteractiveAuth``
- ``MatrixClient/MatrixLogout``
- ``MatrixClient/MatrixServerInfoRequest``
- ``MatrixClient/MatrixSync``

### Error
- ``MatrixClient/MatrixServerError``
- ``MatrixClient/MatrixError``
