import Foundation

/*
public final class Runes: WritableAssets {
	public typealias Contents = [RunePath]
	public typealias Raw = [RunePath]
	
	public static let shared = load()
	public var contents: [RunePath] = []
	public static let assetIdentifier = "runesReforged"
	public static let imageURLBase = "perk-images"
	public var version = "N/A"
	
	public required init() {}
}

public struct RunePath: Asset {
	public typealias Provider = Runes
	
	public var id: Int
	public var key: String
	public var name: String
	public var slots: [[Rune]]
	
	public var imageName: String
	
	public var imageURL: URL? {
		return URL(string: "cdn/img/\(imageName)", relativeTo: Client.baseURL)
	}
	
	public init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
		
		try id = container →! .id
		try key = container →! .key
		try name = container →! .name
		
		if let slots = try? container →! .slots as [[Rune]] {
			self.slots = slots
		} else {
			let rawSlots = try container →! .slots as [RawSlot]
			slots = rawSlots.map { $0.runes }
		}
		
		try imageName = container → .imageName ?? dataContainer →! .imageName
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case imageName = "icon"
	}
	
	private struct RawSlot: Decodable {
		var runes: [Rune]
	}
}

public struct Rune: Codable {
	public var id: Int
	public var key: String
	public var name: String
	public var summary: String
	public var description: String
	
	public var imageName: String
	
	public var imageURL: URL? {
		return URL(string: "cdn/img/\(imageName)", relativeTo: Client.baseURL)
	}
	
	public init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
		
		try id = container →! .id
		try key = container →! .key
		try name = container →! .name
		try summary = container → .summary ?? dataContainer →! .summary
		try description = container → .description ?? dataContainer →! .description
		
		try imageName = container →! .imageName ?? dataContainer →! .imageName
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case summary = "shortDesc"
		case description = "longDesc"
		case imageName = "icon"
	}
}
*/
