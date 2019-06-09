import Foundation

public struct SummonerRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let summonerID: SummonerID
	
	public var method: String {
		return "v4/summoners/\(summonerID)"
	}
	
	public init(summonerID: SummonerID) {
		self.summonerID = summonerID
	}
}

public struct SummonerByAccountRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let accountID: AccountID
	
	public var method: String {
		return "v4/summoners/by-account/\(accountID)"
	}
	
	public init(accountID: AccountID) {
		self.accountID = accountID
	}
}

public struct SummonerByNameRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let name: String
	
	public var method: String {
		return "v4/summoners/by-name/\(name)"
	}
	
	public init(name: String) {
		self.name = name
	}
}

public struct SummonerByPUUIDRequest: Request {
	public typealias Response = Summoner
	public static let base = APIBase.summoner
	
	private let puuid: PUUID
	
	public var method: String {
		return "v4/summoners/by-puuid/\(puuid)"
	}
	
	public init(puuid: PUUID) {
		self.puuid = puuid
	}
}
