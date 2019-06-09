import Foundation

public struct ChampionMasteryRequest: Request {
	public typealias Response = [ChampionMasteryDetails]
	public static let base = APIBase.championMastery
	
	private let summonerID: SummonerID
	
	public var method: String {
		return "v4/champion-masteries/by-summoner/\(summonerID)"
	}
	
	public init(summonerID: SummonerID) {
		self.summonerID = summonerID
	}
	
	public init(for summoner: Summoner) {
		self.summonerID = summoner.id
	}
}
