//
//  Asset.swift
//  LeagueHelper
//
//  Created by Julian Dunskus on 14/07/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

public protocol Assets: class, Codable {
	
	init()
	
	typealias Contents = [AssetID: AssetType]
	
	/// shared singleton
	static var shared: Self { get }
	
	/// the type that this asset container contains
	associatedtype AssetType: Asset where AssetType.Provider == Self
	
	/// what the assets are keyed with in riot's JSON
	typealias AssetID = AssetType.ID
	
	/// what should be put in the URL for the json and/or images
	static var assetIdentifier: String { get }
	
	/// assets provided by this provider
	var contents: Contents { get }
	
	/// current version of these assets
	var version: String { get }
	
	/// updates the `contents` and `version` to new values, applying transformations if necessary
	func updateContents(to newContents: Contents, version: String)
}

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

// MARK: searching
extension Assets {
	
	/**
	Computes a list of assets matching a search query.
	
	The query is first reduced to simple lowercase letters, for easier matching.
	
	- Parameters:
		- query: the search query to match against
		- ordering:
			How to order results depending on match quality. You can also use this to filter out unwanted results (like matches on alternate names). Type inference allows you to just put a period and get a nice list of predefined ordering in autocomplete. Alternatively, you can define your own by passing a custom array.
			
			The default ordering is `[MatchQuality].recommended`.
	
	- Returns: a list of IDs of matching assets, in order of descending match quality
	*/
	public func assets(matchingQuery query: String, ordering: [MatchQuality] = .recommended) -> [AssetID] {
		let query = query.reducedToSimpleLetters()
		var matches: [MatchQuality: Set<AssetID>] = [:]
		
		for (id, asset) in contents {
			func register(as kind: MatchQuality) {
				matches[kind, default: []].insert(id)
			}
			
			// kinda wish I could unify these two in a clean way
			
			// matching on name
			let name = asset.name.reducedToSimpleLetters()
			if name == query {
				register(as: .perfect)
			}
			if name.hasPrefix(query) {
				register(as: .fromStart)
			}
			for sub in name.substrings(after: " ") {
				if sub.hasPrefix(query) {
					register(as: .fromWithin)
					break
				}
			}
			
			// matching on alternate names
			let alternates = asset.searchTerms.map { $0.reducedToSimpleLetters() }
			for alt in alternates {
				if alt == query {
					register(as: .alternatePerfect)
				}
				if alt.hasPrefix(query) {
					register(as: .alternateFromStart)
				}
				for sub in alt.substrings(after: " ") {
					if sub.hasPrefix(query) {
						register(as: .fromWithin)
						break
					}
				}
			}
		}
		
		return ordering.flatMap { matches[$0] ?? [] } // TODO make ordered set to avoid multiple occurrences!
	}
}

/// describes how well an asset matches a given search query 
public enum MatchQuality { // TODO maybe possibly move inside Assets
	/// a perfect match: the original query is exactly equal to the asset name — e.g. "trinity force" for Trinity Force
	case perfect
	/// the query matches the beginning of the asset name, but does not equal it (yet) — e.g. "trinity fo" or "trin" for Trinity Force
	case fromStart
	/// the query matches the beginning of the asset name after dropping some preceding words — e.g. "forc" for Trinity Force
	case fromWithin
	/// like `perfect`, but for an alternate name of the asset — e.g. "triforce" or "tons of damage" for Trinity Force
	case alternatePerfect
	/// like `fromStart`, but for an alternate name of the asset — e.g. "trif" or "ton" for Trinity Force
	case alternateFromStart
	/// like `bad`, but for an alternate name of the asset — e.g. "dam" for Trinity Force
	case alternateFromWithin
}

// just having a bit of fun here tbh
/// a couple of likely orderings of search results
extension Array where Element == MatchQuality {
	/// recommended ordering: perfect matches (allowing alternates), then any other matches on the name, then matches on the alternate name
	public static let recommended: [MatchQuality] = [.perfect, .alternatePerfect, .fromStart, .fromWithin, .alternateFromStart, .alternateFromWithin]
	/// include all matches, preferring matches on the name over alternate names in each quality category (perfect, from start, from within) separately
	public static let byQuality: [MatchQuality] = [.perfect, .alternatePerfect, .fromStart, .alternateFromStart, .fromWithin, .alternateFromWithin]
	/// include all matches, listing all matches on the name before any on the alternate names
	public static let alternatesLast: [MatchQuality] = [.perfect, .fromStart, .fromWithin, .alternatePerfect, .alternateFromStart, .alternateFromWithin]
	/// include matches on the alternate name only if perfect, right after regular perfect matches
	public static let onlyPerfectAlternates: [MatchQuality] = [.perfect, .alternatePerfect, .fromStart, .fromWithin]
	/// include only matches on the actual name
	public static let noAlternateNames: [MatchQuality] = [.perfect, .fromStart, .fromWithin]
}

// MARK: -

public protocol Asset: Codable, Hashable {
	
	associatedtype Provider: Assets
	associatedtype ID: Codable, Hashable
	
	var id: ID { get }
	var name: String { get }
	var description: String { get }
	var version: String! { get }
	
	/// these will be used when searching for the asset, and the name should be the first item TODO is this still true?
	var searchTerms: [String] { get }
	
	/// the name of the image file for this asset on riot's servers; used to compute `imageURL`
	var imageName: String { get }
}

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
		for char in description.characters { // TODO just use an iterator or something
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
