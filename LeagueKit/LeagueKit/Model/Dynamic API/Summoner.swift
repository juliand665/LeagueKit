// Created by Julian Dunskus

import Foundation

public struct ID<T>: Hashable {
	let rawValue: String
}

extension ID: Codable {
	public init(from decoder: Decoder) throws {
		self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
	}
	
	public func encode(to encoder: Encoder) throws {
		try encoder.singleValueContainer() <- { try $0.encode(rawValue) }
	}
}

extension ID: CustomStringConvertible {
	public var description: String {
		return rawValue
	}
}

/// player universally unique identifier (poo-eye-dee)
public typealias PUUID = ID<Player>

public enum Account {}
public typealias AccountID = ID<Account>

public typealias SummonerID = ID<Summoner>

public struct Summoner: Codable {
	public var id: SummonerID
	public var puuid: PUUID
	public var name: String
	public var level: Int
	public var iconID: Int
	public var lastChangeTime: Date
	
	private enum CodingKeys: String, CodingKey {
		case id
		case puuid
		case name
		case level = "summonerLevel"
		case iconID = "profileIconId"
		case lastChangeTime = "revisionDate"
	}
}
