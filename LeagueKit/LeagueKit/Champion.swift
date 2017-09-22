//
//  Champion.swift
//  LeagueKit
//
//  Created by Julian Dunskus on 17/07/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

public final class Champions: WritableAssets {
	public static let shared = load()
	public var contents: [String: Champion] = [:]
	public static let assetIdentifier = "champion"
	public var version = "N/A"
	
	public init() {}
}

public struct Champion: WritableAsset {
	public typealias Provider = Champions
	
	public var id: String
	public var name: String
	public var description: String
	public var title: String
	public var searchTerms: [String]
	public var stats: Stats
	
	public var version: String!
	
	public var imageName: String
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
		
		try id = container →! .id
		try name = container →! .name
		try title = container →! .title
		try version = container →! .version as String
		try description = container → .description ?? dataContainer →! .description
		try searchTerms = container → .searchTerms ?? dataContainer →! .searchTerms
		try imageName = container → .imageName ?? dataContainer.decode(ImageData.self, forKey: .imageData).full
		try stats = container →? .stats ?? Stats(dataFrom: decoder) // need `→?` here because otherwise it'll try to decode the Swift `Stats` structure from riot's json, producing an error, which would make the initializer fail if we were using `→`
	}
	
	/// translate riot's data into something usable
	private enum DataCodingKeys: String, CodingKey {
		case description = "blurb"
		case searchTerms = "tags"
		case imageData = "image"
		case statsData = "stats"
	}
}

// protocols can't be nested in other things for whatever reason
public protocol ScalingStat: Codable {
	func value(atLevel level: Int) -> Double
}

/// a statistic that scales with champion level
extension ScalingStat {
	func growth(atLevel level: Int) -> Double {
		return (7 * (pow(Double(level), 2) - 1) + 267 * Double(level - 1)) / 400
	}
}

/// attack speed is a little more complicated than the other `ScalableStat`s, but you can use it just the same way as other `ScalingStat`s
public struct AttackSpeed: ScalingStat {
	public let offset: Double
	public let percentagePerLevel: Double
	
	public var base: Double {
		return 0.625 / (1 + offset)
	}
	
	public func value(atLevel level: Int) -> Double {
		return base * (1 + 0.01 * percentagePerLevel * growth(atLevel: level))
	}
	
	/// initialize from raw riot data
	init(dataFrom decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DataCodingKeys.self)
		
		try offset = container →! .offset
		try percentagePerLevel = container →! .percentagePerLevel
	}
	
	private enum DataCodingKeys: String, CodingKey {
		case offset = "attackspeedoffset"
		case percentagePerLevel = "attackspeedperlevel"
	}
}

/// a statistic that scales with level the regular way (i.e. not attack speed)
public struct SimpleScalingStat: ScalingStat {
	public let base: Double
	public let perLevel: Double
	
	init(named name: String, dataFrom decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CustomKey.self)
		
		try base = container →! .named(name)
		try perLevel = container →! .named(name + "perlevel")
	}
	
	public func value(atLevel level: Int) -> Double {
		return base + perLevel * growth(atLevel: level)
	}
}

/// a statistic that can regenerate, i.e. health and mana
public struct RegeneratingStat: Codable {
	public let max: SimpleScalingStat
	public let regen: SimpleScalingStat
	
	init(named name: String, dataFrom decoder: Decoder) throws {
		try max = .init(named: name, dataFrom: decoder)
		try regen = .init(named: name + "regen", dataFrom: decoder)
	}
}

extension Champion {
	/// use this to access a champion's stats
	public struct Stats: Codable {
		public let movementSpeed: Double
		public let attackRange: Double
		public let health: RegeneratingStat
		public let mana: RegeneratingStat
		public let armor: SimpleScalingStat
		public let magicResist: SimpleScalingStat
		public let attackDamage: SimpleScalingStat
		public let attackSpeed: AttackSpeed
		
		/// initialize from raw riot data
		init(dataFrom decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: DataCodingKeys.self)
			
			try movementSpeed = container →! .movementSpeed
			try attackRange = container →! .attackRange
			
			try health = RegeneratingStat(named: "hp", dataFrom: decoder)
			try mana = RegeneratingStat(named: "mp", dataFrom: decoder)
			try armor = SimpleScalingStat(named: "armor", dataFrom: decoder)
			try magicResist = SimpleScalingStat(named: "spellblock", dataFrom: decoder)
			try attackDamage = SimpleScalingStat(named: "attackdamage", dataFrom: decoder)
			
			try attackSpeed = AttackSpeed(dataFrom: decoder)
		}
		
		/// translate riot's data into something usable
		private enum DataCodingKeys: String, CodingKey {
			case movementSpeed = "movespeed"
			case attackRange = "attackrange"
		}
	}
}
