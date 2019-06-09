// Created by Julian Dunskus

import Foundation

public struct MatchList: Codable {
	public var startIndex: Int
	public var endIndex: Int
	public var totalGames: Int
	public var matches: [MatchReference]
}

public struct MatchReference: Codable {
	public var matchID: Int
	public var time: Date
	public var championID: Int
	public var season: Int
	public var queue: Queue
	public var lane: Lane
	public var role: Role
	
	private enum CodingKeys: String, CodingKey {
		case matchID = "gameId"
		case time = "timestamp"
		case championID = "champion"
		case season
		case queue
		case lane
		case role
	}
}

public struct Player: Codable {
	public var summonerName: String
	public var summonerID: Int?
	public var accountID: Int
	public var profileIconID: Int
	public var matchHistoryPath: String
	
	private enum CodingKeys: String, CodingKey {
		case summonerName
		case summonerID = "summonerId"
		case accountID = "accountId"
		case profileIconID = "profileIcon"
		case matchHistoryPath = "matchHistoryUri"
	}
}

public struct ParticipantIdentity: Codable {
	public var participantID: Int
	public var player: Player
	
	private enum CodingKeys: String, CodingKey {
		case participantID = "participantId"
		case player
	}
}

public struct Participant: Codable {
	public var participantID: Int
	public var teamID: Int
	public var championID: Int
	
	private enum CodingKeys: String, CodingKey {
		case participantID = "participantId"
		case teamID = "teamId"
		case championID = "championId"
	}
}

public struct Ban: Codable {
	public var championID: Int
	public var pickTurn: Int
	
	private enum CodingKeys: String, CodingKey {
		case championID = "championId"
		case pickTurn
	}
}

public enum Outcome: String, Codable {
	case victory = "Win"
	case defeat = "Fail"
}

public struct TeamStats: Codable {
	public var teamID: Int
	public var outcome: Outcome
	public var bans: [Ban]
	public var gotFirstBlood: Bool
	public var towerKillCount: Int
	public var gotFirstTower: Bool
	public var dragonKillCount: Int
	public var gotFirstDragon: Bool
	public var inhibitorKillCount: Int
	public var gotFirstInhibitor: Bool
	public var riftHeraldKillCount: Int
	public var gotFirstRiftHerald: Bool
	public var baronKillCount: Int
	public var gotFirstBaron: Bool
	public var vilemawKillCount: Int
	public var dominionScore: Int
	
	private enum CodingKeys: String, CodingKey {
		case teamID = "teamId"
		case outcome = "win"
		case bans = "bans"
		case gotFirstBlood = "firstBlood"
		case towerKillCount = "towerKills"
		case gotFirstTower = "firstTower"
		case dragonKillCount = "dragonKills"
		case gotFirstDragon = "firstDragon"
		case inhibitorKillCount = "inhibitorKills"
		case gotFirstInhibitor = "firstInhibitor"
		case riftHeraldKillCount = "riftHeraldKills"
		case gotFirstRiftHerald = "firstRiftHerald"
		case baronKillCount = "baronKills"
		case gotFirstBaron = "firstBaron"
		case vilemawKillCount = "vilemawKills"
		case dominionScore = "dominionVictoryScore"
	}
}

public typealias MatchID = ID<Match>
public struct Match: Codable {
	public var matchID: Int
	public var startTime: Date
	public var duration: TimeInterval // technically an Int, but this is more natural
	public var season: Season
	public var queue: Queue
	public var mode: GameMode
	public var type: GameType
	public var map: Map
	public var participantIdentities: [ParticipantIdentity]
	public var participants: [Participant]
	public var teamStats: [TeamStats]
	
	private enum CodingKeys: String, CodingKey {
		case matchID = "gameId"
		case startTime = "gameCreation"
		case duration = "gameDuration"
		case season = "seasonId"
		case queue = "queueId"
		case type = "gameType"
		case mode = "gameMode"
		case map = "mapId"
		case participantIdentities
		case participants
		case teamStats = "teams"
	}
}
