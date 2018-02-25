//
//  Asset.swift
//  LeagueHelper
//
//  Created by Julian Dunskus on 14/07/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

public protocol Assets: class, Codable { // class-only for (obvious) performance reasons
	typealias Contents = [AssetID: AssetType]
	
	/// the type that this asset container contains
	associatedtype AssetType: Asset where AssetType.Provider == Self
	
	/// what the assets are keyed with in riot's JSON
	typealias AssetID = AssetType.ID
	
	/// shared singleton
	static var shared: Self { get }
	
	/// what should be put in the URL for the json and/or images
	static var assetIdentifier: String { get }
	
	/// assets provided by this provider
	var contents: Contents { get }
	
	/// current version of these assets
	var version: String { get }
	
	init()
	
	/// updates the `contents` and `version` to new values, applying transformations if necessary
	func updateContents(to newContents: Contents, version: String)
}

// MARK: default implementation of updateContents
protocol WritableAssets: Assets where AssetType: WritableAsset {
	/// list of assets provided by this class
	var contents: Contents { get set }
	
	/// current version of these assets
	var version: String { get set }
}

extension WritableAssets {
	public func updateContents(to newContents: Contents, version: String) {
		contents = newContents
		for key in contents.keys {
			contents[key]!.version = version 
		}
	}
}

// MARK: saving and loading
private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

extension Assets {
	/// loads data from defaults
	public static func load() -> Self {
		if let data = UserDefaults.standard.data(forKey: "LoLAPI.\(Self.assetIdentifier)"),
		   let assets = try? decoder.decode(Self.self, from: data) {
			return assets
		} else {
			return Self()
		}
	}
	
	/// saves data to defaults as "LolAPI.`assetIdentifier`"
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

public protocol Asset: Codable, Hashable {
	associatedtype Provider: Assets
	associatedtype ID: Codable, Hashable
	
	var id: ID { get }
	var name: String { get }
	var description: String { get }
	var version: String! { get }
	
	/// these will be used when searching for the asset
	var searchTerms: [String] { get }
	
	/// the name of the image file for this asset on riot's servers; used to compute `imageURL`
	var imageName: String { get }
}

// MARK: default implementation of updateContents
protocol WritableAsset: Asset {
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
extension Asset {
	/// URL of the full-resolution image riot offers for this asset
	var imageURL: URL? {
		return URL(string: "cdn/\(version!)/img/\(Provider.assetIdentifier)/\(imageName)", relativeTo: Requester.baseURL)
	}
	
	/// the `desc` property without all the html tags
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
