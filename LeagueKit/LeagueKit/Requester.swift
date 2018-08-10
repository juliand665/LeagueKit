import Foundation

public final class Requester {
	/**
	List of available versions of riot's data. The list is sorted by descending release date, i.e. the newest version is the first entry in the list.
	Update this using `updateVersions(completion:)`
	*/
	public static var versions: [String] = []
	
	static let baseURL = URL(string: "http://ddragon.leagueoflegends.com")!
	
	/// The version of assets to request from the server. If `nil`, the newest version will be used.
	public var desiredVersion: String?
	
	/**
	This closure is called by `handle` when an error occurs in the decoding process.
	It might not be called on the main queue, so you should wrap any UI-related calls in something like `DispatchQueue.main.async`.
	
	Assign `nil` to not handle any errors.
	
	The closure takes a `RequestError` and either handles it, returning `true`, or ignores it, returning `false`.
	*/
	public var errorHandler: ((RequestError) -> (Bool))?
	
	private func apiURL(for string: String) -> URL? {
		return URL(string: "api/\(string)", relativeTo: Requester.baseURL)
	}
	
	private func dataURL(for string: String, inLanguage language: String = "en_US") -> URL? {
		return URL(string: "cdn/\(version)/data/\(language)/\(string)", relativeTo: Requester.baseURL)
	}
	
	let responseDecoder = JSONDecoder() <- {
		$0.userInfo[.useAPIFormat] = true
	}
	
	var version: String {
		guard let version = desiredVersion ?? Requester.versions.first else {
			handle(.incorrectAPIUsage(description: "You need to either set your desiredVersion or call updateVersions(completion:) before requesting anything else. More errors will follow."))
			return "[N/A]" // make URL construction fail
		}
		return version
	}
	
	/// Creates a new `Requester` for you to configure the `errorHandler` or `desiredVersion` of.
	public init(errorHandler: ((RequestError) -> (Bool))? = nil) {
		self.errorHandler = errorHandler
	}
	
	/**
	Asynchronously does the following:
	1. Requests and decodes the list of versions from Riot, handling any errors with `handle(_:)`
	2. Stores the list in `Requester.versions`
	3. Calls `completion`
	
	- Parameters:
		- completion: Called when finished. (The list of versions can be found in the corresponding static property.)
	*/
	public func updateVersions(completion: (() -> Void)? = nil) {
		decode([String].self, fromJSONAt: apiURL(for: "versions.json")) { (versions) in
			defer { completion?() }
			guard let versions = versions else { return }
			guard !versions.isEmpty else {
				self.handle(.unexpectedObject(description: "Expected non-empty array of strings (got empty one)."))
				return
			}
			Requester.versions = versions
		}
	}
	
	/**
	Synchronously does the following:
	1. Requests and decodes the corresponding JSON for the asset provider from riot, handling any errors with `handle(_:)`
	2. Updates the provider with the decoded data using `updateContents(to:version:)`
	3. Calls `completion`
	
	- Parameters:
		- assets: The asset provider to update.
		- forceUpdate: If `true`, updates the assets even if they're at the set version, effectively repairing them.
		- completion: Called when finished. (Asset data can be found in the provider.)
	*/
	public func update<Provider: Assets>(_ assets: Provider, forceUpdate: Bool = false, completion: (() -> Void)? = nil) {
		if forceUpdate || version != assets.version {
			decode(Provider.Raw.self, fromJSONAt: dataURL(for: "\(Provider.assetIdentifier).json")) { (raw) in
				defer { completion?() }
				raw.map { assets.updateContents(to: $0, version: self.version) }
			}
		} else {
			completion?()
		}
	}
	
	/**
	Asynchronously does the following:
	1. Requests the data at a given `URL`
	2. Tries to decode it from JSON to the given `type`
	3. If successful, calls `completion` with the result
	4. Otherwise, handles the error with `handle(_:)`
	
	You shouldn't need to call this function; it's only exposed for documentation purposes.
	
	- Parameters:
		- type: The type to decode. By taking this as argument, the generic type can be inferred instead of being explicitly stated.
		- possibleURL: The location of the data. If this is `nil`, a `RequestError.urlError` is handled.
		- completion: Called with the result of the request/decoding operation, if successful.
	*/
	public func decode<T: Decodable>(_ type: T.Type, fromJSONAt possibleURL: URL?, completion: @escaping (T?) -> Void) {
		getData(at: possibleURL) { (data) in
			guard let data = data else {
				completion(nil)
				return
			}
			do {
				completion(try self.responseDecoder.decode(type, from: data))
			} catch {
				self.handle(.parseError(error: error))
				completion(nil)
			}
		}
	}
	
	private func getData(at possibleURL: URL?, completion: @escaping (Data?) -> Void) {
		if let url = possibleURL {
			let task = URLSession.shared.dataTask(with: url) { (data, _, taskError) in
				guard taskError == nil, let data = data else {
					let errorToHandle = taskError ?? NSError(localizedDescription: "No data received from data task!")
					self.handle(.requestError(error: errorToHandle))
					completion(nil)
					return
				}
				completion(data)
			}
			task.resume()
		} else {
			handle(.urlError)
			completion(nil)
		}
	}
	
	/**
	Passes the error to `errorHandler`, handling only what `errorHandler` doesn't handle (returns `false` for) by printing something to the console.
	
	You shouldn't need to call this function; it's only exposed for documentation purposes.
	*/
	public func handle(_ requestError: RequestError) {
		guard errorHandler?(requestError) != true else { // nil != true, false != true
			return
		}
		switch requestError {
		case .urlError:
			print("Could not construct URL!")
		case .requestError(let error):
			print("Could not request data:", error.localizedDescription)
			dump(error)
		case .parseError(let error):
			print("Could not parse JSON data:", error.localizedDescription)
			dump(error)
		case .unexpectedObject(let expected):
			print("Unexpected object in JSON deserialization:", expected)
		case .incorrectAPIUsage(let description):
			print("API used incorrectly:", description)
		}
	}
	
	/// This enum abstracts the errors that can occur during requests. To override the default handling (as implemented in `handle(_:)`), assign your own closure to `errorHandler`.
	public enum RequestError: Error {
		/// Unable to construct the URL. There was probably something wrong with the `assetIdentifier` of the asset provider, causing a malformed URL.
		case urlError
		/// An error occurred in the `URLSessionDataTask`. Likely causes include an unstable internet connection and riot's servers being down.
		case requestError(error: Error)
		/// An error occurred whilst trying to parse the JSON received from riot.
		case parseError(error: Error)
		/// The JSON parse was successful, but the result is not what we expected (e.g. an empty array instead of a non-empty one)
		case unexpectedObject(description: String)
		/// You, the user of this API, did something wrong.
		case incorrectAPIUsage(description: String)
	}
}
