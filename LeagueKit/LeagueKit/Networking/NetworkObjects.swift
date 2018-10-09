import Foundation

public protocol Request {
	associatedtype Response: Decodable
	
	static var base: APIBase { get }
	var method: String { get }
	
	var parameters: [String: Any] { get }
}

public extension Request {
	var parameters: [String: Any] {
		return [:]
	}
}

/// The response received if something went wrong, e.g. `statusCode == 403` likely indicates an outdated API Key.
public struct Status: Decodable {
	public var statusCode: Int
	public var message: String
	
	public init(from decoder: Decoder) throws {
		let outer = try decoder.container(keyedBy: OuterKeys.self)
		let container = try outer.nestedContainer(keyedBy: CodingKeys.self, forKey: .status)
		try statusCode = container.decodeValue(forKey: .statusCode)
		try message = container.decodeValue(forKey: .message)
	}
	
	private enum OuterKeys: CodingKey {
		case status
	}
	
	private enum CodingKeys: String, CodingKey {
		case statusCode = "status_code"
		case message
	}
}

public enum APIRegion: String {
	case br = "br1"
	case eune = "eun1"
	case euw = "euw1"
	case jp = "jp1"
	case kr = "kr"
	case lan = "la1"
	case las = "la2"
	case na = "na1"
	case oce = "oc1"
	case tr = "tr1"
	case ru = "ru"
	case pbe = "pbe1"
}

/// The base for the method we're calling
public enum APIBase: String {
	case championMastery = "champion-mastery"
	case champion = "platform"
	case league
	case status
	case match
	case spectator
	case summoner
}
