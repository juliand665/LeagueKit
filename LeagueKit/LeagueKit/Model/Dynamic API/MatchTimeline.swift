// Created by Julian Dunskus

import Foundation

public struct MatchTimeline: Codable {
	public var frames: [Frame]
	public var frameInterval: Int
	
	public struct Frame: Codable {
		public var timestamp: Int
		public var events: [Event]
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			try timestamp = container.decodeValue(forKey: .timestamp)
			
			let rawEvents: [RawEvent] = try container.decodeValue(forKey: .events)
			events = rawEvents.map { $0.event }
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode(timestamp, forKey: .timestamp)
			
			let rawEvents = events.map(RawEvent.init)
			try container.encode(rawEvents, forKey: .events)
		}
		
		private enum CodingKeys: String, CodingKey {
			case timestamp
			case events
		}
	}
}

fileprivate struct RawEvent: Codable {
	let identifier: EventIdentifier
	let event: Event
	
	init(containing event: Event) {
		self.event = event
		self.identifier = EventIdentifier.allCases.first { $0.type == type(of: event) }!
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		try identifier = container.decodeValue(forKey: .identifier)
		try event = identifier.type.init(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(identifier, forKey: .identifier)
		try event.encode(to: encoder)
	}
	
	private enum CodingKeys: String, CodingKey {
		case identifier = "type"
	}
}

public protocol Event: Codable {}

enum EventIdentifier: String, Codable, CaseIterable {
	case championKill = "CHAMPION_KILL"
	case wardPlacement = "WARD_PLACED"
	case wardKill = "WARD_KILL"
	case buildingKill = "BUILDING_KILL"
	case eliteMonsterKill = "ELITE_MONSTER_KILL"
	case itemPurchase = "ITEM_PURCHASED"
	case itemSale = "ITEM_SOLD"
	case itemDestruction = "ITEM_DESTROYED"
	case itemUndo = "ITEM_UNDO"
	case skillLevelUp = "SKILL_LEVEL_UP"
	case ascendedEvent = "ASCENDED_EVENT"
	case pointCapture = "POINT_CAPTURE"
	case poroKingSummon = "PORO_KING_SUMMONED"
	
	var type: Event.Type {
		switch self {
		case .championKill:
			return ChampionKill.self
		case .wardPlacement:
			return WardPlacement.self
		case .wardKill:
			return WardKill.self
		case .buildingKill:
			return BuildingKill.self
		case .eliteMonsterKill:
			return EliteMonsterKill.self
		case .itemPurchase:
			return ItemPurchase.self
		case .itemSale:
			return ItemSale.self
		case .itemDestruction:
			return ItemDestruction.self
		case .itemUndo:
			return ItemUndo.self
		case .skillLevelUp:
			return SkillLevelUp.self
		case .ascendedEvent:
			return AscendedEvent.self
		case .pointCapture:
			return PointCapture.self
		case .poroKingSummon:
			return PoroKingSummon.self
		}
	}
}

public struct ChampionKill: Event {
	public var killerID: Int
	public var victimID: Int
	public var assisterIDs: [Int]
	
	private enum CodingKeys: String, CodingKey {
		case killerID = "killerId"
		case victimID = "victimId"
		case assisterIDs = "assistingParticipantIds"
	}
}

public struct WardPlacement: Event {
	// TODO
}

public struct WardKill: Event {
	// TODO
}

public struct BuildingKill: Event {
	// TODO
}

public struct EliteMonsterKill: Event {
	// TODO
}

public struct ItemPurchase: Event {
	// TODO
}

public struct ItemSale: Event {
	// TODO
}

public struct ItemDestruction: Event {
	// TODO
}

public struct ItemUndo: Event {
	// TODO
}

public struct SkillLevelUp: Event {
	// TODO
}

public struct AscendedEvent: Event {
	// TODO
}

public struct PointCapture: Event {
	// TODO
}

public struct PoroKingSummon: Event {
	// TODO
}
