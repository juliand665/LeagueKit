import Foundation
import Promise

public final class StaticDataClient {
	public static let shared = StaticDataClient()
	
	private static let baseURL = URLComponents(string: "https://ddragon.leagueoflegends.com")!
	static func dataURL(path: String) -> URL {
		return (baseURL <- { $0.path = path }).url!
	}
	
	/// List of available versions of riot's data. The list is sorted by descending release date, i.e. the newest version is the first entry in the list.
	public private(set) var versions: [String] = []
	
	/// The version of assets to request from the server. If `nil`, the newest version will be used.
	public var desiredVersion: String?
	
	// internal for testing
	let responseDecoder = JSONDecoder() <- {
		$0.userInfo[.useAPIFormat] = true
		$0.dateDecodingStrategy = .millisecondsSince1970
	}
	
	private let urlSession = URLSession.shared
	
	public init() {}
	
	/// You can call this method explicitly to update `versions`, but they will be updated for you automatically if they've never been fetched before.
	public func updateVersions() -> Future<[String]> {
		return decode([String].self, fromJSONAt: StaticDataClient.dataURL(path: "/api/versions.json"))
			.guard {
				guard !$0.isEmpty else {
					throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Expected non-empty array of version strings (got empty one)."))
				}
			}
			.then { self.versions = $0 }
	}
	
	/**
	- Parameters:
		- provider: The asset provider to update.
		- forceUpdate: If `true`, updates the assets even if they're at the desired version, effectively repairing them.
	*/
	public func update<Provider: AssetProvider>(_ provider: Provider, forceUpdate: Bool = false) -> Future<Void> {
		return requestedVersion().flatMap { version in
			guard forceUpdate || version != provider.version else { return .fulfilled(with: ()) }
			return self.resourceURL(for: "\(Provider.assetIdentifier).json").flatMap {
				self.decode(Provider.Raw.self, fromJSONAt: $0, version: version).map { raw in
					provider.updateContents(to: raw, version: version)
				}
			}
		}
	}
	
	private func resourceURL(for string: String, inLanguage language: String = "en_US") -> Future<URL> {
		return requestedVersion().map { version in
			StaticDataClient.dataURL(path: "/cdn/\(version)/data/\(language)/\(string)")
		}
	}
	
	private func requestedVersion() -> Future<String> {
		if let version = desiredVersion ?? versions.first {
			return .fulfilled(with: version)
		} else {
			return updateVersions().map { $0.first! }
		}
	}
	
	private func decode<T: Decodable>(_ type: T.Type, fromJSONAt url: URL, version: String? = nil) -> Future<T> {
		return urlSession.dataTask(with: url).map { [responseDecoder] in
			return try (responseDecoder <- { $0.userInfo[.assetVersion] = version })
				.decode(type, from: $0.data)
		}
	}
}
