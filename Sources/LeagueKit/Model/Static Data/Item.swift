import Foundation

public final class Items: WritableAssetProvider {
	public typealias AssetType = Item
	public typealias Raw = SimpleRaw<Items>
	
	public static let shared = load()
	public static let assetIdentifier = "item"
	
	public var contents: [Int: Item] = [:]
	public var version = "N/A"
	
	public required init() {}
}

public final class Item: SimpleAsset {
	public typealias Provider = Items
	
	public let id: Int
	public let name: String
	public let description: String
	public let requiredChampion: String?
	public let summary: String
	public let searchTerms: [String]
	
	public let version: String
	
	public let imageName: String
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		if decoder.useAPIFormat {
			let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try id = decoder.codingPath.last?.intValue
				??? DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "expected int as key in item dictionary!")
			try summary = dataContainer.decodeValue(forKey: .summary)
			try searchTerms = dataContainer.decode(String.self, forKey: .searchTerms)
				.components(separatedBy: ";")
				.filter { !$0.isEmpty }
			version = decoder.assetVersion!
			try imageName = dataContainer.decode(ImageData.self, forKey: .imageData).full
		} else {
			try id = container.decodeValue(forKey: .id)
			try summary = container.decodeValue(forKey: .summary)
			try searchTerms = container.decodeValue(forKey: .searchTerms)
			try version = container.decodeValue(forKey: .version)
			try imageName = container.decodeValue(forKey: .imageName)
		}
		
		try name = container.decodeValue(forKey: .name)
		try description = container.decodeValue(forKey: .description)
		try requiredChampion = container.decodeValueIfPresent(forKey: .requiredChampion)
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case summary = "plaintext"
		case searchTerms = "colloq"
		case imageData = "image"
	}
}
