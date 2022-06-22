//
//  Interactive.swift
//
//
//  Created by Finn Behrens on 09.03.22.
//

import AnyCodable
import Foundation

public struct MatrixInteractiveAuth: MatrixResponse {
    public init(
        flows: [MatrixInteractiveAuth.Flow],
        params: [String: AnyCodable],
        session: String? = nil,
        completed: [MatrixLoginFlowType]? = nil
    ) {
        self.flows = flows
        self.params = params
        self.session = session
        self.completed = completed
    }

    public var flows: [Flow]

    /// This section contains any information that the client will need to know in order to use a given type of authentication.
    /// For each authentication type presented, that type may be present as a key in this dictionary.
    /// For example, the public part of an OAuth client ID could be given here.
    public var params: [String: AnyCodable]

    /// This is a session identifier that the client must pass back to the homeserver, if one is provided,
    /// in subsequent attempts to authenticate in the same API call.
    public var session: String?

    public var completed: [MatrixLoginFlowType]?

    // MARK: Dynamic vars

    public var notCompletedStages: [Flow] {
        var ret: [Flow] = []
        for flow in flows {
            var stages: [MatrixLoginFlowType] = []
            for stage in flow.stages {
                if !(completed?.contains(stage) ?? false) {
                    stages.append(stage)
                }
            }
            ret.append(.init(stages: stages))
        }
        return ret
    }

    /// Return the next stage, which did not yet complete, from the first login flow
    public var nextStage: MatrixLoginFlowType? {
        notCompletedStages[0].stages[0]
    }

    /// Return the next stage, which did not yet complete, from the ferst login flow with the optional parameters.
    public var nextStageWithParams: LoginFlowWithParams? {
        guard let nextStage = nextStage else {
            return nil
        }

        let params = params[nextStage.rawValue]
        return LoginFlowWithParams(flow: nextStage, params: params)
    }

    // MARK: Functions

    /// Test if the given login flow is supported by the home server.
    /// This returns true, the flow is contained in one or more stages.  This means the flow could be required.
    public func isOptional(_ flow: MatrixLoginFlowType) -> Bool {
        flows.first { $0.stages.contains(flow) } != nil
    }

    public func isOptional(notCompletedFlow flow: MatrixLoginFlowType) -> Bool {
        notCompletedStages.first { $0.stages.contains(flow) } != nil
    }

    /// Test if th given flow is required by every flow supported by the homeserver.
    public func isRequierd(_ flow: MatrixLoginFlowType) -> Bool {
        flows.allSatisfy { $0.stages.contains(flow) }
    }

    public func isRequierd(notCompletedFlow flow: MatrixLoginFlowType) -> Bool {
        notCompletedStages.allSatisfy { $0.stages.contains(flow) }
    }

    // MARK: Struct

    enum CodingKeys: String, CodingKey {
        case session
        case flows
        case params
        case completed
    }

    public struct LoginFlowWithParams {
        public let flow: MatrixLoginFlowType
        public let params: AnyCodable?
    }
}

public extension MatrixInteractiveAuth {
    struct Flow: Codable {
        public var stages: [MatrixLoginFlowType] = []
    }
}

/// struct to return to server
public struct MatrixInteractiveAuthResponse: Codable {
    public var session: String?

    public var type: MatrixLoginFlowType?

    public var extraInfo: [String: AnyCodable]

    public init(session: String? = nil, type: MatrixLoginFlowType?, extraInfo: [String: AnyCodable] = [:]) {
        self.session = session
        self.type = type
        self.extraInfo = extraInfo
    }

    public init(recaptchaResponse: String, session: String? = nil) {
        type = MatrixLoginFlowType.recaptcha
        self.session = session
        extraInfo = ["response": AnyCodable(stringLiteral: recaptchaResponse)]
    }

    public init(emailClientSecret clientSecret: String, emailSID sid: String, session: String? = nil) {
        type = MatrixLoginFlowType.email
        self.session = session
        extraInfo = [
            "threepid_creds": [
                "client_secret": clientSecret,
                "sid": sid,
            ],
        ] as [String: AnyCodable]
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
            nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnownCodingKeys.self)
        session = try container.decodeIfPresent(String.self, forKey: .session)
        type = try container.decode(MatrixLoginFlowType.self, forKey: .type)

        extraInfo = [:]
        let extraContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)

        for key in extraContainer.allKeys where KnownCodingKeys.doesNotContain(key) {
            let decoded = try extraContainer.decode(
                AnyCodable.self,
                forKey: DynamicCodingKeys(stringValue: key.stringValue)!
            )
            self.extraInfo[key.stringValue] = decoded
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KnownCodingKeys.self)
        try container.encodeIfPresent(session, forKey: .session)
        try container.encodeIfPresent(type?.rawValue, forKey: .type)

        var extraContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (name, value) in extraInfo {
            try extraContainer.encode(value, forKey: .init(stringValue: name)!)
        }
    }
}
