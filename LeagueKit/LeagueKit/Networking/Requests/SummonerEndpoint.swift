import Foundation

public struct SummonerRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let summonerID: Int
	
	public var method: String {
		return "summoners/\(summonerID)"
	}
	
	public init(summonerID: Int) {
		self.summonerID = summonerID
	}
}

public struct SummonerByAccountRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let accountID: Int
	
	public var method: String {
		return "summoners/by-account/\(accountID)"
	}
	
	public init(accountID: Int) {
		self.accountID = accountID
	}
}

public struct SummonerByNameRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let name: String
	
	public var method: String {
		return "summoners/by-name/\(name)"
	}
	
	public init(name: String) {
		self.name = name
	}
}
