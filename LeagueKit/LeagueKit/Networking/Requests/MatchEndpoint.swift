import Foundation

public struct MatchListRequest: Request {
	public typealias Response = MatchList
	public static let base = APIBase.match
	
	private let accountID: Int
	
	public var method: String {
		return "matchlists/by-account/\(accountID)"
	}
	
	public init(forAccount accountID: Int) {
		self.accountID = accountID
	}
}

public struct MatchRequest: Request {
	public typealias Response = Match
	public static let base = APIBase.match
	
	private let matchID: Int
	
	public var method: String {
		return "matches/\(matchID)"
	}
	
	public init(forMatch matchID: Int) {
		self.matchID = matchID
	}
}

public struct MatchTimelineRequest: Request {
	public typealias Response = MatchTimeline
	public static let base = APIBase.match
	
	private let matchID: Int
	
	public var method: String {
		return "timelines/by-match/\(matchID)"
	}
	
	public init(forMatch matchID: Int) {
		self.matchID = matchID
	}
}