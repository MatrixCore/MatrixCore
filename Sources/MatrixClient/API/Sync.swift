import Foundation

public struct MatrixSyncRequest: MatrixRequest {
    public func components(for homeserver: MatrixHomeserver, with parameters: URLParameters) throws -> URLComponents {
        var components = homeserver.url
        components.path = "/_matrix/client/r0/sync"

        var queryItems = [URLQueryItem]()

        if let filter = parameters.filter {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }

        if let since = parameters.since {
            queryItems.append(URLQueryItem(name: "since", value: since))
        }

        // TODO: fullState
        // TODO: presence

        if let timeout = parameters.timeout {
            queryItems.append(URLQueryItem(name: "timeout", value: String(timeout)))
        }

        components.queryItems = queryItems

        return components
    }
    
    public typealias Response = MatrixSyncResponse
    
    public typealias URLParameters = Parameters
    
    public static var httpMethod: HttpMethod = .GET
    
    public static var requiresAuth = true
    
    public struct Parameters {
        public let filter: String?
        public let since: String?
        public let fullState: Bool?
        public let presence: Presence?
        public let timeout: Int?
        
        public enum Presence: String {
            case online
            case offline
            case unavailable
        }
        
        public init(filter: String? = nil,
                    since: String? = nil,
                    fullState: Bool? = nil,
                    presence: MatrixSyncRequest.Parameters.Presence? = nil,
                    timeout: Int? = nil) {
            self.filter = filter
            self.since = since
            self.fullState = fullState
            self.presence = presence
            self.timeout = timeout
        }
    }
}

public struct MatrixSyncResponse: MatrixResponse {
    public let nextBatch: String
    public let rooms: Rooms?
    // public let presence: Presence
    // public let account_data: AccountData
    // public let to_device: ToDevice
    // public let device_lists: DeviceLists
    // public let device_one_time_keys_count: OneTimeKeysCount
    
    enum CodingKeys: String, CodingKey {
        case nextBatch = "next_batch"
        case rooms
    }
    
    public struct Rooms: Codable {
        public let joined: [String: JoinedRoom]?
        // public let invite: [String: InvitedRoom]?
        public let left: [String: LeftRoom]?
        
        enum CodingKeys: String, CodingKey {
            case joined = "join"
            case left = "leave"
        }
    }
    
    public struct JoinedRoom: Codable {
        public let summary: RoomSummary?
        public let state: State?
        public let timeline: Timeline?
        // public let ephemeral: Ephemeral?
        // public let account_data: AccountData?
        public let unreadNotifications: UnreadNotificationCounts?
        
        enum CodingKeys: String, CodingKey {
            case summary
            case state
            case timeline
            case unreadNotifications = "unread_notifications"
        }
        
        public struct RoomSummary: Codable {
            public let heroes: [String]?
            public let joinedMemberCount: Int?
            public let invitedMemberCount: Int?
            
            enum CodingKeys: String, CodingKey {
                case heroes = "m.heroes"
                case joinedMemberCount = "m.joined_member_count"
                case invitedMemberCount = "m.invited_member_count"
            }
        }
        
        public struct State: Codable {
            @MatrixCodableEvents
            public var events: [MatrixEvent]?
        }
        
        public struct Timeline: Codable {
            @MatrixCodableEvents
            public var events: [MatrixEvent]?
            public let isLimited: Bool?
            public let previousBatch: String?
            
            enum CodingKeys: String, CodingKey {
                case events
                case isLimited = "limited"
                case previousBatch = "prev_batch"
            }
        }
        
        public struct UnreadNotificationCounts: Codable {
            public let highlightCount: Int?
            public let notificationCount: Int?
            
            enum CodingKeys: String, CodingKey {
                case highlightCount = "highlight_count"
                case notificationCount = "notification_count"
            }
        }
    }
    
    public struct LeftRoom: Codable {
        // public let state: State
        // public let timeline: Timeline
        // public let account_data: AccountData
    }
    
}
