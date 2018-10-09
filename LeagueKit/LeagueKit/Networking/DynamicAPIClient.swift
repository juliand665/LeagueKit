import Foundation
import Promise

public final class Client {
	private let apiKey: String
	private let region: APIRegion
	private let baseURL: URLComponents
	
	private let urlSession = URLSession.shared
	private let responseDecoder = JSONDecoder() <- {
		$0.dateDecodingStrategy = .millisecondsSince1970
	}
	
	/// - note: You should never expose your api key publicly, so make sure to only use this class from a server you control or in privately distributed apps.
	public init(apiKey: String, region: APIRegion) {
		self.apiKey = apiKey
		self.region = region
		self.baseURL = URLComponents(string: "https://\(region.rawValue).api.riotgames.com")!
	}
	
	public func send<R: Request>(_ request: R) -> Future<R.Response> {
		return Future.fulfilled(with: request)
			.map(urlRequest)
			.flatMap(send)
			.map(responseDecoder.decode)
	}
	
	private func urlRequest<R: Request>(request: R) throws -> URLRequest {
		let components = baseURL <- {
			$0.path = "/lol/\(R.base.rawValue)/v3/\(request.method)"
			$0.queryItems = request.parameters
				.mapValues(String.init(describing:))
				.map(URLQueryItem.init)
		}
		return URLRequest(url: components.url!)
			<- { $0.addValue(apiKey, forHTTPHeaderField: "X-Riot-Token") }
	}
	
	private func send(_ request: URLRequest) -> Future<Data> {
		return urlSession.dataTask(with: request)
			.guard { taskResult in
				// status is returned instead of an actual response if something goes wrong
				if let status = try? self.responseDecoder.decode(Status.self, from: taskResult.data) {
					throw RequestError.apiError(status, taskResult.response)
				}
			}
			.map { $0.data }
			.flatMapError { error in
				switch error {
				case RequestError.apiError(let status, let response) where status.statusCode == 429:
					let retryDelay = response.allHeaderFields["Retry-After"].flatMap { TimeInterval($0 as! String) }
					print("rate limited; retrying after", retryDelay?.description ?? "unspecified delay")
					return Future.fulfilled(with: request)
						.asyncAfter(deadline: .now() + (retryDelay ?? 1), on: .main)
						.flatMap(self.send)
				default:
					throw error
				}
			}
			.catch { dump($0) }
	}
}

/// An error that occurs while interfacing with the server.
public enum RequestError: Error {
	/// The server returned a status object, indicating an error.
	case apiError(Status, HTTPURLResponse)
}
