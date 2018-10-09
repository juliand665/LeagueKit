// Created by Julian Dunskus

import Foundation

public struct Summoner: Codable {
	public var id: Int
	public var name: String
	public var level: Int
	public var iconID: Int
	public var lastChangeTime: Date
	
	private enum CodingKeys: String, CodingKey {
		case id
		case name
		case level = "summonerLevel"
		case iconID = "profileIconId"
		case lastChangeTime = "revisionDate"
	}
}
