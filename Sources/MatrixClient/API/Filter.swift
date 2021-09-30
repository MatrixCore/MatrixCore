//
//  File.swift
//  File
//
//  Created by Finn Behrens on 07.08.21.
//

import Foundation

public struct MatrixFilterId: MatrixResponse {
    public var user: String?
    public var filter: String?
    
    public init(user: String? = nil, filter: String? = nil) {
        self.user = user
        self.filter = filter
    }
    
    private enum CodingKeys: String, CodingKey {
        case filter = "filter_id"
    }
}

public struct MatrixFilterRequest: MatrixRequest {
    public typealias Response = MatrixFilter
    
    public typealias URLParameters = MatrixFilterId
    
    public func path(with parameters: MatrixFilterId) throws -> String {
        // FIXME: url encode
        guard
            let userId = parameters.user,
            let filterId = parameters.filter
        else {
            throw MatrixError.Unrecognized
        }
        return "/_matrix/client/r0/user/\(userId)/filter/\(filterId)"
    }
    
    public static var httpMethod = HttpMethod.GET
    
    public static var requiresAuth = true
}

public struct MatrixFilter: MatrixResponse {
    /// List of event fields to include. If this list is absent then all fields are included. The entries may include '.'
    /// characters to indicate sub-fields. So ['content.body'] will include the 'body' field of the 'content' object.
    /// A literal '.' character in a field name may be escaped using a '\'. A server may include more fields than were requested.
    public var eventFields: [String]?
    
    /// The format to use for events. 'client' will return the events in a format suitable for clients. 'federation' will return the raw
    /// event as received over federation. The default is 'client'.
    public var eventFormat: EventFormat? = .client
    
    /// The presence updates to include.
    public var presence: EventFilter?
    
    /// The user account data that isn't associated with rooms to include.
    public var accountData: EventFilter?
    
    /// Filters to be applied to room data.
    public var room: RoomFilter?
    
    enum CodingKeys: String, CodingKey {
        case eventFields = "event_fields"
        case eventFormat = "event_format"
        case presence
        case accountData = "account_data"
    }
    
    public enum EventFormat: String, Codable {
        case client
        case federation
    }
    
    public struct EventFilter: Codable {
        /// The maximum number of events to return.
        public var limit: Int?
        
        /// A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be
        /// excluded even if it is listed in the '`senders`' filter.
        public var notSenders: [String]?
        
        /// A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be
        /// excluded even if it is listed in the 'types' filter. A '*' can be used as a wildcard to match any sequence of characters.
        public var notTypes: [String]?
        
        /// A list of senders IDs to include. If this list is absent then all senders are included.
        public var senders: [String]?
        
        /// A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a
        /// wildcard to match any sequence of characters.
        public var types: [String]?
        
        
        enum CodingKeys: String, CodingKey {
            case limit
            case notSenders = "not_senders"
            case notTypes = "not_types"
            case senders
            case types
        }
    }
    
    public struct RoomFilter: Codable {
        /// A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded
        /// even if it is listed in the '`rooms`' filter. This filter is applied before the filters in `ephemeral`, `state`, `timeline` or `account_data`
        public var notRooms: [String]?
        
        /// A list of room IDs to include. If this list is absent then all rooms are included. This filter is applied before the filters in `ephemeral`, `state`,
        /// `timeline` or `account_data`
        public var rooms: [String]?
        
        /// The events that aren't recorded in the room history, e.g. typing and receipts, to include for rooms.
        public var ephemeral: RoomEventFilter?
        
        /// Include rooms that the user has left in the sync, default false
        public var includeLeave: Bool?
        
        /// The state events to include for rooms.
        public var state: StateFilter?
        
        /// The message and state update events to include for rooms.
        public var timeline: RoomEventFilter?
        
        /// The per user account data to include for rooms.
        public var accountData: RoomEventFilter?
        
        enum CodingKeys: String, CodingKey {
            case notRooms = "not_rooms"
            case rooms
            case ephemeral
            case includeLeave = "include_leave"
            case state
            case timeline
            case accountData = "account_data"
        }
        
        public struct RoomEventFilter: Codable {
            
            /// The maximum number of events to return.
            public var limit: Int?
            
            /// A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the '`senders`' filter.
            public var notSenders: [String]?
            
            /// A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the '`types`' filter.
            /// A '*' can be used as a wildcard to match any sequence of characters.
            public var notTypes: [String]?

            /// A list of senders IDs to include. If this list is absent then all senders are included.
            public var senders: [String]?
            
            /// A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
            public var types: [String]?
            
            /// If `true`, enables lazy-loading of membership events. See
            /// [Lazy-loading room members](https://matrix.org/docs/spec/client_server/latest#lazy-loading-room-members)
            /// for more information. Defaults to `false`.
            public var lazyLoadMembers: Bool?
            
            /// If `true`, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless `lazyLoadMembers` is `true`.
            /// See [Lazy- loading room members](https://matrix.org/docs/spec/client_server/latest#lazy-loading-room-members) for more information.
            /// Defaults to `false`.
            public var includeRedundantMembers: Bool?
            
            /// A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the '`rooms`' filter.
            public var notRooms: [String]?
            
            /// A list of room IDs to include. If this list is absent then all rooms are included.
            public var rooms: [String]?
            
            /// If `true`, includes only events with a url key in their content. If `false`, excludes those events. If omitted, `url` key is not considered for filtering.
            public var containsUrl: Bool?
            
            enum CodingKeys: String, CodingKey {
                case limit
                case notSenders = "not_senders"
                case notTypes = "not_types"
                case senders
                case types
                case lazyLoadMembers = "lazy_load_members"
                case includeRedundantMembers = "include_redundant_members"
                case notRooms = "not_rooms"
                case rooms
                case containsUrl = "contains_url"
            }
        }
        
        public struct StateFilter: Codable {
            /// The maximum number of events to return.
            public var limit: Int?
            
            /// A list of sender IDs to exclude. If this list is absent then no senders are excluded. A matching sender will be excluded even if it is listed in the '`senders`' filter.
            public var notSenders: [String]?
            
            /// A list of event types to exclude. If this list is absent then no event types are excluded. A matching type will be excluded even if it is listed in the '`types`' filter.
            /// A '*' can be used as a wildcard to match any sequence of characters.
            public var notTypes: [String]?

            /// A list of senders IDs to include. If this list is absent then all senders are included.
            public var senders: [String]?
            
            /// A list of event types to include. If this list is absent then all event types are included. A '*' can be used as a wildcard to match any sequence of characters.
            public var types: [String]?
            
            /// If `true`, enables lazy-loading of membership events. See
            /// [Lazy-loading room members](https://matrix.org/docs/spec/client_server/latest#lazy-loading-room-members)
            /// for more information. Defaults to `false`.
            public var lazyLoadMembers: Bool?
            
            /// If `true`, sends all membership events for all events, even if they have already been sent to the client. Does not apply unless `lazyLoadMembers` is `true`.
            /// See [Lazy- loading room members](https://matrix.org/docs/spec/client_server/latest#lazy-loading-room-members) for more information.
            /// Defaults to `false`.
            public var includeRedundantMembers: Bool?
            
            /// A list of room IDs to exclude. If this list is absent then no rooms are excluded. A matching room will be excluded even if it is listed in the '`rooms`' filter.
            public var notRooms: [String]?
            
            /// A list of room IDs to include. If this list is absent then all rooms are included.
            public var rooms: [String]?
            
            /// If `true`, includes only events with a url key in their content. If `false`, excludes those events. If omitted, `url` key is not considered for filtering.
            public var containsUrl: Bool?
            
            enum CodingKeys: String, CodingKey {
                case limit
                case notSenders = "not_senders"
                case notTypes = "not_types"
                case senders
                case types
                case lazyLoadMembers = "lazy_load_members"
                case includeRedundantMembers = "include_redundant_members"
                case notRooms = "not_rooms"
                case rooms
                case containsUrl = "contains_url"
            }
        }
    }
}

extension MatrixFilter: MatrixRequest {
    public typealias Response = MatrixFilterId
    
    public typealias URLParameters = String
    
    /// with -> userId
    public func path(with parameters: String) -> String {
        // TODO: url encode
        return "/_matrix/client/r0/user/\(parameters)/filter"
    }
    
    public static var httpMethod = HttpMethod.POST
    
    public static var requiresAuth = true
}

public extension MatrixFilter {
    struct FilterId: MatrixResponse {
        var filterId: String
        
        enum CodingKeys: String, CodingKey {
            case filterId = "filter_id"
        }
    }
}
