//
//  Item.swift
//  LeagueKit
//
//  Created by Julian Dunskus on 11/07/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

public final class Items: WritableAssets {
	
	public static let shared = load()
	public var contents: [Int: Item] = [:]
	public static let assetIdentifier = "item"
	public var version = "N/A"
	
	public required init() {}
}

public struct Item: WritableAsset {
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
		id = container[.id] ?? key ?? -1
		version = container[.version] // will be set in `Items.updateContents(to:version:)` if not present, i.e. after decoding riot's json
		name = container[.name]!
		description = container[.description]!
		requiredChampion = container[.requiredChampion]
		summary = container[.summary] ?? dataContainer[.summary]!
		imageName = try container[.imageName] ?? dataContainer.decode(ImageData.self, forKey: .imageData).full
		
		if container.contains(.searchTerms) {
			searchTerms = container[.searchTerms]!
		} else {
			let termsString: String = dataContainer[.searchTerms]!
			var termsData = termsString.components(separatedBy: ";")
			termsData.append(name.reducedToSimpleLetters())
			termsData = termsData
				.map { $0.reducedToSimpleLetters() }
				.filter { !$0.isEmpty }
			searchTerms = termsData
		}
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case summary = "plaintext"
		case searchTerms = "colloq"
		case imageData = "image"
	}
}
