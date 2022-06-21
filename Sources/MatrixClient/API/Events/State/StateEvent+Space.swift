//
//  File.swift
//  
//
//  Created by Finn Behrens on 29.04.22.
//

import Foundation

public extension MatrixRoomCreateEvent.RoomType {
    static let space: Self = "m.space"
}

/// Defines the relationship of a child room to a space-room. Has no effect in rooms which are not <doc:Spaces>.
public struct MatrixRoomSpaceChildEvent: MatrixStateEventType {
    public init(order: String? = nil, suggested: Bool? = false, via: [String]? = nil) {
        self.order = order
        self.suggested = suggested
        self.via = via
    }

    public static let type = "m.space.child"

    /// Optional string to define ordering among space children. These are lexicographically compared against other children’s order, if present.
    ///
    /// Must consist of ASCII characters within the range \x20 (space) and \x7E (~), inclusive. Must not exceed 50 characters.
    ///
    /// order values with the wrong type, or otherwise invalid contents, are to be treated as though the order key was not provided.
    // TODO: ordering type?
    public var order: String?

    /// Optional (default false) flag to denote whether the child is “suggested” or of interest to members of the space.
    ///
    /// This is primarily intended as a rendering hint for clients to display the room differently, such as eagerly rendering them in the room list.
    public var suggested: Bool? = false

    /// A list of servers to try and join through.
    ///
    /// When not present or invalid, the child room is not considered to be part of the space.
    public var via: [String]?
}

public struct MatrixRoomSpaceParentEvent: MatrixStateEventType {
    public init(canonical: Bool? = false, via: [String]?) {
        self.canonical = canonical
        self.via = via
    }

    public static let type: String = " m.space.parent"

    /// Optional (default false) flag to denote this parent is the primary parent for the room.
    ///
    /// When multiple canonical parents are found, the lowest parent when ordering by room ID lexicographically by Unicode code-points should be used.
    public var canonical: Bool? = false

    /// A list of servers to try and join through.
    ///
    /// When not present or invalid, the child room is not considered to be part of the space.
    public var via: [String]?
}
