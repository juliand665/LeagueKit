import Foundation

public final class Runes: WritableAssetProvider {
	public typealias AssetType = RunePath
	public typealias Raw = [RunePath]
	
	public static let shared = load()
	public static let assetIdentifier = "runesReforged"
	
	public var contents: [RunePath] = []
	public var version = "N/A"
	
	public required init() {}
}

public struct RunePath: Asset {
	public typealias Provider = Runes
	
	public let id: Int
	public let key: String
	public let name: String
	public let slots: [[Rune]]
	
	public let imageName: String
	
	public var imageURL: URL? {
		return URL(string: "cdn/img/\(imageName)", relativeTo: Client.baseURL)
	}
	
	public init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		
		if decoder.useAPIFormat {
			let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try slots = container.decode([RawSlot].self, forKey: .slots).map { $0.runes }
			try imageName = dataContainer.decodeValue(forKey: .imageName)
		} else {
			try slots = container.decodeValue(forKey: .slots)
			try imageName = container.decodeValue(forKey: .imageName)
		}
		
		try id = container.decodeValue(forKey: .id)
		try key = container.decodeValue(forKey: .key)
		try name = container.decodeValue(forKey: .name)
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case imageName = "icon"
	}
	
	private struct RawSlot: Decodable {
		var runes: [Rune]
	}
}

public struct Rune: Codable, Equatable {
	public let id: Int
	public let key: String
	public let name: String
	public let summary: String
	public let description: String
	
	public let imageName: String
	
	public var imageURL: URL? {
		return URL(string: "cdn/img/\(imageName)", relativeTo: Client.baseURL)
	}
	
	public init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer = try decoder.container(keyedBy: CodingKeys.self)
		if decoder.useAPIFormat {
			let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try summary = dataContainer.decodeValue(forKey: .summary)
			try description = dataContainer.decodeValue(forKey: .description)
			try imageName = dataContainer.decodeValue(forKey: .imageName)
		} else {
			try summary = container.decodeValue(forKey: .summary)
			try description = container.decodeValue(forKey: .description)
			try imageName = container.decodeValue(forKey: .imageName)
		}
		
		try id = container.decodeValue(forKey: .id)
		try key = container.decodeValue(forKey: .key)
		try name = container.decodeValue(forKey: .name)
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case summary = "shortDesc"
		case description = "longDesc"
		case imageName = "icon"
	}
}
