import Foundation

public protocol Assets: AnyObject, Codable { // class-only for (obvious) performance reasons
	associatedtype Contents: Codable
	associatedtype Raw: Decodable
	
	/// the type that this asset container contains
	associatedtype AssetType: Asset where AssetType.Provider == Self
	
	/// what the assets are keyed with in riot's JSON
	typealias AssetID = AssetType.ID
	
	/// shared singleton
	static var shared: Self { get }
	
	/// what should be put in the URL for the json and/or (by default) images
	static var assetIdentifier: String { get }
	
	/// assets provided by this provider
	var contents: Contents { get }
	
	/// current version of these assets
	var version: String { get }
	
	init()
	
	/// updates the `contents` and `version` to new values, applying transformations if necessary
	func updateContents(to raw: Raw, version: String)
	
	/// loads data from defaults
	static func load() -> Self
	
	/// saves data to defaults as "LolAPI.`assetIdentifier`"
	static func save()
}

// MARK: default implementation of updateContents

public protocol WritableAssets: Assets {
	/// list of assets provided by this class
	var contents: Contents { get set }
	
	/// current version of these assets
	var version: String { get set }
}

extension WritableAssets where Raw == Contents {
	public func updateContents(to raw: Raw, version: String) {
		self.version = version
		contents = raw
		if Self.shared === self {
			Self.save()
		}
	}
}

public struct SimpleRaw<Provider: Assets>: Decodable {
	var data: [Provider.AssetID: Provider.AssetType]
}

extension WritableAssets where
	AssetType: WritableAsset,
	Raw == SimpleRaw<Self>,
	Contents == [AssetID: AssetType]
{
	public func updateContents(to raw: Raw, version: String) {
		self.version = version
		contents = raw.data
		for key in contents.keys {
			contents[key]!.version = version
		}
		if Self.shared === self {
			Self.save()
		}
	}
}

// MARK: saving and loading
private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension Assets {
	public static func load() -> Self {
		if let data = UserDefaults.standard.data(forKey: "LoLAPI.\(Self.assetIdentifier)"),
		   let assets = try? decoder.decode(Self.self, from: data) {
			return assets
		} else {
			return Self()
		}
	}
	
	public static func save() {
		do {
			let data = try encoder.encode(shared)
			UserDefaults.standard.set(data, forKey: "LoLAPI.\(Self.assetIdentifier)")
		} catch {
			print("Error while encoding \(Self.self):")
			print(error)
		}
	}
}

// MARK: -

typealias SimpleAsset = WritableAsset & DescribedAsset & VersionedAsset & SearchableAsset

public protocol Asset: Codable, Hashable {
	associatedtype Provider: Assets
	associatedtype ID: Codable, Hashable
	
	var id: ID { get }
	var name: String { get }
	
	/// the name of the image file for this asset on riot's servers; used to compute `imageURL`
	var imageName: String { get }
	
	/// the full url of the image file for the current version, if available
	var imageURL: URL? { get }
}

protocol VersionedAsset: Asset {
	var version: String! { get }
}

// MARK: default implementation of updateContents
public protocol WritableAsset: Asset {
	var version: String! { get set }
}

// MARK: hashing and equality
extension Asset {
	public var hashValue: Int {
		return id.hashValue
	}
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}

// MARK: convenient functions
extension VersionedAsset {
	/// URL of the full-resolution image riot offers for this asset
	public var imageURL: URL? {
		return URL(string: "cdn/\(version!)/img/\(Provider.assetIdentifier)/\(imageName)", relativeTo: Client.baseURL)
	}
}

// MARK: -

public protocol DescribedAsset: Asset {
	var description: String { get }
	
	/// the `desc` property without all the html tags
	func prettyDescription() -> String
}

public extension DescribedAsset {
	public func prettyDescription() -> String {
		var pretty = ""
		
		var between: String?
		for char in description {
			if let contents = between {
				if char == ">" {
					if contents.reducedToSimpleLetters(allowingSpaces: false) == "br" {
						pretty.append("\n")
					}
					between = nil
				} else {
					between!.append(char)
				}
			} else {
				if char == "<" {
					between = ""
				} else {
					pretty.append(char)
				}
			}
		}
		
		return pretty
	}
}

// MARK: -

/// only used to decode riot's JSON
struct ImageData: Codable {
	var full: String
}

extension Decoder {
	var useAPIFormat: Bool {
		get { return userInfo[.useAPIFormat] as? Bool == true }
	}
}

extension CodingUserInfoKey {
	static let useAPIFormat = CodingUserInfoKey(rawValue: "LeagueKit.useAPIFormat")!
}
