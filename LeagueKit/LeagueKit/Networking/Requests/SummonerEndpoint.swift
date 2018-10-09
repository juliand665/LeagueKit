import Foundation

public struct SummonerRequest: Request {
	public typealias ExpectedResponse = Summoner
	public static let base = APIBase.summoner
	
	private let accountID: Int
	
	public var method: String {
		return "summoners/by-account/\(accountID)"
	}
	
	public init(accountID: Int) {
		self.accountID = accountID
	}
}
