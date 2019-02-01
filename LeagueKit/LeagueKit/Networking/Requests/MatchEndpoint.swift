import Foundation

public struct MatchListRequest: Request {
	public typealias Response = MatchList
	public static let base = APIBase.match
	
	private let accountID: AccountID
	
	public var method: String {
		return "v4/matchlists/by-account/\(accountID)"
	}
	
	public init(forAccount accountID: AccountID) {
		self.accountID = accountID
	}
}

public struct MatchRequest: Request {
	public typealias Response = Match
	public static let base = APIBase.match
	
	private let matchID: MatchID
	
	public var method: String {
		return "v4/matches/\(matchID)"
	}
	
	public init(forMatch matchID: MatchID) {
		self.matchID = matchID
	}
}

public struct MatchTimelineRequest: Request {
	public typealias Response = MatchTimeline
	public static let base = APIBase.match
	
	private let matchID: MatchID
	
	public var method: String {
		return "v4/timelines/by-match/\(matchID)"
	}
	
	public init(forMatch matchID: MatchID) {
		self.matchID = matchID
	}
}
