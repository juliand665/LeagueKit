//
//  AssetSearching.swift
//  LeagueKit
//
//  Created by Julian Dunskus on 10.08.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Foundation

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
public enum MatchQuality { // wish I could define this as a subtype of `Assets` in an extension
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
