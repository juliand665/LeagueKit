import Foundation

public struct ChampionMasteryRequest: Request {
	public typealias Response = [ChampionMastery]
	public static let base = APIBase.championMastery
	
	private let summonerID: Int
	
	public var method: String {
		return "champion-masteries/by-summoner/\(summonerID)"
	}
	
	public init(summonerID: Int) {
		self.summonerID = summonerID
	}
	
	public init(for summoner: Summoner) {
		self.summonerID = summoner.id
	}
}
