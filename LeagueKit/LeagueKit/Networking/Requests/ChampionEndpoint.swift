import Foundation

public struct ChampionRotationRequest: Request {
	public static let base = APIBase.champion
	
	public var method: String {
		return "champion-rotations"
	}
	
	public init() {}
	
	public struct Response: Decodable {
		var freeChampions: [Int]
		var freeChampionsForNewPlayers: [Int]
		var maxNewPlayerLevel: Int
		
		private enum CodingKeys: String, CodingKey {
			case freeChampions = "freeChampionIds"
			case freeChampionsForNewPlayers = "freeChampionIdsForNewPlayers"
			case maxNewPlayerLevel = "maxNewPlayerLevel"
		}
	}
}
