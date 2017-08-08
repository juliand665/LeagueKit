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
		
		id = container[.id]!
		name = container[.name]!
		title = container[.title]!
		version = container[.version]
		description = container[.description] ?? dataContainer[.description]!
		imageName = try container[.imageName] ?? dataContainer.decode(ImageData.self, forKey: .imageData).full
		stats = try container[.stats] ?? Stats(dataFrom: decoder)
		
		if container.contains(.searchTerms) {
			searchTerms = container[.searchTerms]!
		} else {
			var termsData: [String] = dataContainer[.searchTerms]!
			termsData.append(name)
			termsData = termsData
				// "The Black Cleaver" -> ["Cleaver", "Black Cleaver", "The Black Cleaver"]
				.flatMap { $0.components(separatedBy: " ").reversed().scan { $1 + $0 } ?? [] }
				// "The Black Cleaver" -> "theblackcleaver"
				.map { $0.reducedToSimpleLetters() }
				.filter { !$0.isEmpty }
			searchTerms = termsData
		}
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

/// a statistic that scales with level
extension ScalingStat {
	func growth(atLevel level: Int) -> Double {
		return (7 * (pow(Double(level), 2) - 1) + 267 * Double(level - 1)) / 400
	}
}

/// attack speed is a little more complicated than the other `ScalableStat`s, but you can use it just the same way as a `LevelDependentStat`
public struct AttackSpeed: ScalingStat {
	public let offset: Double
	public let percentagePerLevel: Double
	
	public var base: Double {
		return 0.625 / (1 + offset)
	}
	
	public func value(atLevel level: Int) -> Double {
		return base * (1 + 0.01 * percentagePerLevel * growth(atLevel: level))
	}
}

/// a statistic that scales with level the regular way (i.e. not attack speed)
public struct SimpleScalingStat: ScalingStat {
	public let base: Double
	public let perLevel: Double
	
	public func value(atLevel level: Int) -> Double {
		return base + perLevel * growth(atLevel: level)
	}
}

/// a statistic that can regenerate, i.e. health and mana
public struct RegeneratingStat: Codable {
	public let max: SimpleScalingStat
	public let regen: SimpleScalingStat
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
			
			movementSpeed = container[.movementSpeed]!
			attackRange = container[.attackRange]!
			
			health = RegeneratingStat(max:   SimpleScalingStat(base: container[.health]!,      perLevel: container[.healthPerLevel]!),
			                          regen: SimpleScalingStat(base: container[.healthRegen]!, perLevel: container[.healthRegenPerLevel]!))
			mana = RegeneratingStat(max:   SimpleScalingStat(base: container[.mana]!,      perLevel: container[.manaPerLevel]!),
			                        regen: SimpleScalingStat(base: container[.manaRegen]!, perLevel: container[.manaRegenPerLevel]!))
			
			armor        = SimpleScalingStat(base: container[.armor]!,        perLevel: container[.armorPerLevel]!)
			magicResist  = SimpleScalingStat(base: container[.magicResist]!,  perLevel: container[.magicResistPerLevel]!)
			attackDamage = SimpleScalingStat(base: container[.attackDamage]!, perLevel: container[.attackDamagePerLevel]!)
			
			attackSpeed = AttackSpeed(offset: container[.attackSpeedOffset]!, percentagePerLevel: container[.attackSpeedPercentPerLevel]!)
		}
		
		/// translate riot's data into something usable
		private enum DataCodingKeys: String, CodingKey {
			case movementSpeed = "movespeed"
			case attackRange = "attackrange"
			case health = "hp", healthPerLevel = "hpperlevel"
			case healthRegen = "hpregen", healthRegenPerLevel = "hpregenperlevel"
			case mana = "mp", manaPerLevel = "mpperlevel"
			case manaRegen = "mpregen", manaRegenPerLevel = "mpregenperlevel"
			case armor = "armor", armorPerLevel = "armorperlevel"
			case magicResist = "spellblock", magicResistPerLevel = "spellblockperlevel"
			case attackDamage = "attackdamage", attackDamagePerLevel = "attackdamageperlevel"
			case attackSpeedOffset = "attackspeedoffset", attackSpeedPercentPerLevel = "attackspeedperlevel"
		}
	}
}
