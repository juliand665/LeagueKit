// Created by Julian Dunskus

import Foundation

public struct ChampionMasteryDetails: Codable {
	public var level: Int
	public var points: Int
	public var pointsSinceLastLevel: Int
	public var pointsUntilNextLevel: Int
	public var tokensEarned: Int
	public var hasReceivedChest: Bool
	public var championID: Int
	public var lastPlayTime: Date
	
	private enum CodingKeys: String, CodingKey {
		case level = "championLevel"
		case points = "championPoints"
		case pointsSinceLastLevel = "championPointsSinceLastLevel"
		case pointsUntilNextLevel = "championPointsUntilNextLevel"
		case tokensEarned
		case hasReceivedChest = "chestGranted"
		case championID = "championId"
		case lastPlayTime
	}
}
