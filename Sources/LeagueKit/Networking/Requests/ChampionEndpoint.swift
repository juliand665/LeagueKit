import Foundation

public struct ChampionRotationRequest: Request {
	public static let base = APIBase.champion
	
	public let method = "v3/champion-rotations"
	
	public init() {}
	
	public struct Response: Decodable {
		public var freeChampions: [Int]
		public var freeChampionsForNewPlayers: [Int]
		public var maxNewPlayerLevel: Int
		
		private enum CodingKeys: String, CodingKey {
			case freeChampions = "freeChampionIds"
			case freeChampionsForNewPlayers = "freeChampionIdsForNewPlayers"
			case maxNewPlayerLevel = "maxNewPlayerLevel"
		}
	}
}
