import Foundation

public final class Champions: WritableAssetProvider {
	public typealias AssetType = Champion
	public typealias Raw = SimpleRaw<Champions>
	
	public static let shared = load()
	public static let assetIdentifier = "champion"
	
	public var contents: [String: Champion] = [:] {
		didSet {
			championsByKey = Dictionary(uniqueKeysWithValues: contents.values.map { ($0.key, $0) })
		}
	}
	public var version = "N/A"
	
	private var championsByKey: [Int: Champion] = [:]
	
	public init() {}
	
	public subscript(_ id: String) -> Champion? {
		return contents[id]
	}
	
	public subscript(_ key: Int) -> Champion? {
		return championsByKey[key]
	}
}

public final class Champion: SimpleAsset {
	public typealias Provider = Champions
	
	public let id: String
	public let key: Int
	public let name: String
	public let description: String
	public let title: String
	public let searchTerms: [String]
	public let stats: Stats
	
	public let version: String
	
	public let imageName: String
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		if decoder.useAPIFormat {
			let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try key = Int(container.decode(String.self, forKey: .key))
					??? DecodingError.dataCorruptedError(forKey: .key, in: container, debugDescription: "key string could not be converted to int")
			try description = dataContainer.decodeValue(forKey: .description)
			try searchTerms = dataContainer.decodeValue(forKey: .searchTerms)
			try imageName = dataContainer.decode(ImageData.self, forKey: .imageData).full
			try stats = container.decode(RawStats.self, forKey: .stats).stats
		} else {
			try key = container.decodeValue(forKey: .key)
			try description = container.decodeValue(forKey: .description)
			try searchTerms = container.decodeValue(forKey: .searchTerms)
			try imageName = container.decodeValue(forKey: .imageName)
			try stats = container.decodeValue(forKey: .stats)
		}
		
		try id = container.decodeValue(forKey: .id)
		try name = container.decodeValue(forKey: .name)
		try title = container.decodeValue(forKey: .title)
		try version = container.decodeValue(forKey: .version)
	}
	
	struct RawStats: Decodable {
		let stats: Stats
		
		init(from decoder: Decoder) throws {
			stats = try Stats(dataFrom: decoder)
		}
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case description = "blurb"
		case searchTerms = "tags"
		case imageData = "image"
	}
}

// protocols can't be nested in other things for whatever reason
public protocol ScalingStat: Codable {
	func value(atLevel level: Int) -> Double
}

/// a statistic that scales with champion level
extension ScalingStat {
	func growth(atLevel level: Int) -> Double {
		return (7 * (pow(Double(level), 2) - 1) + 267 * Double(level - 1)) / 400
	}
}

/// Attack speed is a little different from the other `ScalingStat`s, but you can use it just the same way.
public struct AttackSpeed: ScalingStat {
	public let base: Double
	public let percentagePerLevel: Double
	
	public func value(atLevel level: Int) -> Double {
		return base * (1 + 0.01 * percentagePerLevel * growth(atLevel: level))
	}
	
	/// initialize from raw riot data
	init(dataFrom decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DataCodingKeys.self)
		
		try base = container.decodeValue(forKey: .base)
		try percentagePerLevel = container.decodeValue(forKey: .percentagePerLevel)
	}
	
	private enum DataCodingKeys: String, CodingKey {
		case base = "attackspeed"
		case percentagePerLevel = "attackspeedperlevel"
	}
}

/// a statistic that scales with level the regular way (i.e. not attack speed)
public struct SimpleScalingStat: ScalingStat {
	public let base: Double
	public let perLevel: Double
	
	init(named name: String, dataFrom decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CustomKey.self)
		
		try base = container.decodeValue(forKey: .named(name))
		try perLevel = container.decodeValue(forKey: .named(name + "perlevel"))
	}
	
	public func value(atLevel level: Int) -> Double {
		return base + perLevel * growth(atLevel: level)
	}
}

/// a statistic that can regenerate, i.e. health and mana
public struct RegeneratingStat: Codable {
	public let max: SimpleScalingStat
	public let regen: SimpleScalingStat
	
	init(named name: String, dataFrom decoder: Decoder) throws {
		try max = .init(named: name, dataFrom: decoder)
		try regen = .init(named: name + "regen", dataFrom: decoder)
	}
}

extension Champion {
	/// use this to access a champion's stats
	public final class Stats: Codable {
		public let movementSpeed: Double
		public let attackRange: Double
		public let health: RegeneratingStat
		public let mana: RegeneratingStat
		public let armor: SimpleScalingStat
		public let magicResist: SimpleScalingStat
		public let attackDamage: SimpleScalingStat
		public let attackSpeed: AttackSpeed
		
		/// initialize from raw riot data
		init(dataFrom decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try movementSpeed = container.decodeValue(forKey: .movementSpeed)
			try attackRange = container.decodeValue(forKey: .attackRange)
			
			try health = RegeneratingStat(named: "hp", dataFrom: decoder)
			try mana = RegeneratingStat(named: "mp", dataFrom: decoder)
			try armor = SimpleScalingStat(named: "armor", dataFrom: decoder)
			try magicResist = SimpleScalingStat(named: "spellblock", dataFrom: decoder)
			try attackDamage = SimpleScalingStat(named: "attackdamage", dataFrom: decoder)
			
			try attackSpeed = AttackSpeed(dataFrom: decoder)
		}
		
		/// translate riot's data into something usable
		private enum DataCodingKeys: String, CodingKey {
			case movementSpeed = "movespeed"
			case attackRange = "attackrange"
		}
	}
}
