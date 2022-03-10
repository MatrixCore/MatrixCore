# Resolve Homeserver URL

Resolve the actual homeserver URL from the given well-known url.

## Overview

With ``MatrixHomeserver`` you can resolve a homeserver URL usable by ``MatrixClient/MatrixClient``.

## Resolving
To resolve the homeserver url you need to init ``MatrixHomeserver`` with
``MatrixHomeserver/init(resolve:withUrlSession:)``.

```swift
let homeserver = try await MatrixHomeserver(resolve: "https://matrix.org/")
```

## Topics

### Relationship
- ``MatrixClient/MatrixHomeserver``
- ``MatrixClient/MatrixClient``
