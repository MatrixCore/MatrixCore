//
//  Interactive.swift
//
//
//  Created by Finn Behrens on 09.03.22.
//

import AnyCodable
import Foundation

public struct MatrixInteractiveAuth: MatrixResponse {
    public var flows: [Flow]

    /// This section contains any information that the client will need to know in order to use a given type of authentication.
    /// For each authentication type presented, that type may be present as a key in this dictionary.
    /// For example, the public part of an OAuth client ID could be given here.
    public var params: [String: AnyCodable]

    /// This is a session identifier that the client must pass back to the homeserver, if one is provided,
    /// in subsequent attempts to authenticate in the same API call.
    public var session: String?

    public var completed: [MatrixLoginFlow]?

    public var error: String?
    public var errcode: MatrixError?

    public var notCompletedStages: [Flow] {
        var ret: [Flow] = []
        for flow in flows {
            var stages: [MatrixLoginFlow] = []
            for stage in flow.stages {
                if !(completed?.contains(stage) ?? false) {
                    stages.append(stage)
                }
            }
            ret.append(.init(stages: stages))
        }
        return ret
    }

    public var nextStage: MatrixLoginFlow? {
        notCompletedStages[0].stages[0]
    }

    public var nextStageWithParams: (MatrixLoginFlow, AnyCodable?)? {
        guard let nextStage = nextStage else {
            return nil
        }

        let params = params[nextStage.rawValue]
        return (nextStage, params)
    }

    enum CodingKeys: String, CodingKey {
        case session
        case flows
        case params
        case completed
        case error
        case errcode
    }
}

public extension MatrixInteractiveAuth {
    struct Flow: Codable {
        public var stages: [MatrixLoginFlow] = []
    }
}

/// struct to return to server
public struct MatrixInteractiveAuthResponse: Codable {
    public var session: String?

    public var type: MatrixLoginFlow

    public var extraInfo: [String: AnyCodable]

    public init(session: String? = nil, type: MatrixLoginFlow, extraInfo: [String: AnyCodable] = [:]) {
        self.session = session
        self.type = type
        self.extraInfo = extraInfo
    }

    public init(recaptchaResponse: String, session: String? = nil) {
        type = MatrixLoginFlow.recaptcha
        self.session = session
        extraInfo = ["response": AnyCodable(stringLiteral: recaptchaResponse)]
    }
}

public extension MatrixInteractiveAuthResponse {
    private enum KnownCodingKeys: String, CodingKey, CaseIterable {
        case session
        case type

        static func doesNotContain(_ key: DynamicCodingKeys) -> Bool {
            !Self.allCases.map(\.stringValue).contains(key.stringValue)
        }
    }

    internal struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // not used here, but a protocol requirement
        var intValue: Int?
        init?(intValue _: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        session = try container.decodeIfPresent(String.self, forKey: .session)
        type = try container.decode(MatrixLoginFlow.self, forKey: .type)

        extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)

        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(AnyCodable.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            self.extraInfo[key.stringValue] = decoded
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encodeIfPresent(session, forKey: .session)
        try container.encode(type.rawValue, forKey: .type)

        var extraContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (name, value) in extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}