import Foundation

public final class Items: WritableAssets {
	public typealias AssetID = Int
	public typealias AssetType = Item
	public typealias Contents = [Int: Item]
	public typealias Raw = SimpleRaw<Items>
	
	public static let shared = load()
	public var contents: [Int: Item] = [:]
	public static let assetIdentifier = "item"
	public var version = "N/A"
	
	public required init() {}
}

public struct Item: SimpleAsset {
	public typealias Provider = Items
	
	public var id: Int
	public var name: String
	public var description: String
	public var requiredChampion: String?
	public var summary: String
	public var searchTerms: [String]
	
	public var version: String!
	
	public var imageName: String
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
		
		let key = decoder.codingPath.last?.intValue
		try id = container.decodeValueIfPresent(forKey: .id) ?? key ?? -1
		try version = container.decodeValueIfPresent(forKey: .version) // will be set in `Items.updateContents(to:version:)` if not present, i.e. after decoding riot's json
		try name = container.decodeValue(forKey: .name)
		try description = container.decodeValue(forKey: .description)
		try requiredChampion = container.decodeValueIfPresent(forKey: .requiredChampion)
		try summary = container.decodeValueIfPresent(forKey: .summary)
			?? dataContainer.decodeValue(forKey: .summary)
		try imageName = container.decodeValueIfPresent(forKey: .imageName)
			?? dataContainer.decode(ImageData.self, forKey: .imageData).full
		
		try searchTerms = container.decodeValueIfPresent(forKey: .searchTerms)
			?? dataContainer.decode(String.self, forKey: .searchTerms)
				.components(separatedBy: ";")
				.filter { !$0.isEmpty }
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case summary = "plaintext"
		case searchTerms = "colloq"
		case imageData = "image"
	}
}
