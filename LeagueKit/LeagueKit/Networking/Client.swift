import Foundation
import Promise

public final class Client {
	public static let shared = Client()
	
	/// List of available versions of riot's data. The list is sorted by descending release date, i.e. the newest version is the first entry in the list.
	public private(set) var versions: [String] = []
	
	static let baseURL = URL(string: "https://ddragon.leagueoflegends.com")!
	
	/// The version of assets to request from the server. If `nil`, the newest version will be used.
	public var desiredVersion: String?
	
	// internal for testing
	let responseDecoder = JSONDecoder() <- {
		$0.userInfo[.useAPIFormat] = true
		$0.dateDecodingStrategy = .millisecondsSince1970
	}
	
	private let urlSession = URLSession.shared
	
	public init() {}
	
	/// You can call this method explicitly to update `Client.versions`, but versions will automatically be updated for you if they've never been fetched before.
	public func updateVersions() -> Future<[String]> {
		return decode([String].self, fromJSONAt: apiURL(for: "versions.json")!)
			.guard {
				guard !$0.isEmpty else {
					throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Expected non-empty array of version strings (got empty one)."))
				}
			}
			.then { self.versions = $0 }
	}
	
	/**
	- Parameters:
		- assets: The asset provider to update.
		- forceUpdate: If `true`, updates the assets even if they're at the desired version, effectively repairing them.
	*/
	public func update<Provider: AssetProvider>(_ assets: Provider, forceUpdate: Bool = false) -> Future<Void> {
		return requestedVersion().flatMap { version in
			guard forceUpdate || version != assets.version else { return .fulfilled(with: ()) }
			return self.dataURL(for: "\(Provider.assetIdentifier).json").flatMap {
				self.decode(Provider.Raw.self, fromJSONAt: $0, version: version).map { raw in
					assets.updateContents(to: raw, version: version)
				}
			}
		}
	}
	
	private func apiURL(for string: String) -> URL? {
		return URL(string: "api/\(string)", relativeTo: Client.baseURL)
	}
	
	private func dataURL(for string: String, inLanguage language: String = "en_US") -> Future<URL> {
		return requestedVersion().map { version in
			try URL(string: "cdn/\(version)/data/\(language)/\(string)", relativeTo: Client.baseURL) ??? RequestError.invalidURL
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
	
	/// This enum abstracts the errors that can occur during requests. To override the default handling (as implemented in `handle(_:)`), assign your own closure to `errorHandler`.
	public enum RequestError: Error {
		/// Unable to construct the URL. There was probably something wrong with the `assetIdentifier` of the asset provider, causing a malformed URL.
		case invalidURL
	}
}
