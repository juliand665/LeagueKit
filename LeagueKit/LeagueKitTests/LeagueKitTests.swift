//
//  LeagueKitTests.swift
//  LeagueKitTests
//
//  Created by Julian Dunskus on 13.06.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import XCTest

@testable import LeagueKit

final class LeagueKitTests: XCTestCase {
	let requester = Requester()
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	func testRequestingNewestVersion() throws {
		synchronously(execute: requester.updateVersions)
		XCTAssert(!Requester.versions.isEmpty)
	}
	
	func testDecodingItems() {
		synchronously(execute: requester.updateVersions)
		synchronously { requester.update(Items.shared, completion: $0) }
		XCTAssert(!Items.shared.contents.isEmpty)
	}
	
	func testDecodingChampions() {
		synchronously(execute: requester.updateVersions)
		synchronously { requester.update(Champions.shared, completion: $0) }
		XCTAssert(!Champions.shared.contents.isEmpty)
	}
	
//	func testDecodingRunes() {
//		synchronously(execute: requester.updateVersions)
//		synchronously { requester.update(Runes.shared, completion: $0) }
//		XCTAssert(!Runes.shared.contents.isEmpty)
//	}
	
	func testDecodingAhri() throws {
		try testRequestingNewestVersion()
		
		let ahri = try decoder.decode(Champion.self, from: ahriJSON)
		
		XCTAssert(ahri.name == "Ahri")
		
		XCTAssertNotNil(NSImage(contentsOf: ahri.imageURL!))
		
		XCTAssertEqual(330, ahri.stats.movementSpeed)
		XCTAssertEqual(550, ahri.stats.attackRange)
		
		func checkStat<Stat: ScalingStat>(expecting expected: Double, atLevel level: Int, for path: KeyPath<Champion.Stats, Stat>) {
			XCTAssertEqual(expected, ahri.stats[keyPath: path].value(atLevel: level).rounded(significantFigures: 3))
		}
		
		checkStat(expecting: 572,	atLevel: 2, for: \.health.max)
		checkStat(expecting: 7.39,	atLevel: 3, for: \.health.regen)
		checkStat(expecting: 447,	atLevel: 4, for: \.mana.max)
		checkStat(expecting: 8.47,	atLevel: 5, for: \.mana.regen)
		checkStat(expecting: 34.7,	atLevel: 6, for: \.armor)
		checkStat(expecting: 30.0,	atLevel: 7, for: \.magicResist)
		checkStat(expecting: 70.4,	atLevel: 8, for: \.attackDamage)
		checkStat(expecting: 0.759,	atLevel: 9, for: \.attackSpeed)
	}
	
	func testReencodingAhri() throws {
		let ahri = try decoder.decode(Champion.self, from: ahriJSON)
		let reencoded = try encoder.encode(ahri)
		_ = try decoder.decode(Champion.self, from: reencoded)
	}
	
	let ahriJSON = """
	{
		"version": "7.4.1",
		"id": "Ahri",
		"key": "103",
		"name": "Ahri",
		"title": "the Nine-Tailed Fox",
		"blurb": "Unlike other foxes that roamed the woods of southern Ionia, Ahri had always felt a strange connection to the magical world around her; a connection that was somehow incomplete. Deep inside, she felt the skin she had been born into was an ill fit for her...",
		"info": {
			"attack": 3,
			"defense": 4,
			"magic": 8,
			"difficulty": 5
		},
		"image": {
			"full": "Ahri.png",
			"sprite": "champion0.png",
			"group": "champion",
			"x": 48,
			"y": 0,
			"w": 48,
			"h": 48
		},
		"tags": [
			"Mage",
			"Assassin"
		],
		"partype": "Mana",
		"stats": {
			"hp": 514.4,
			"hpperlevel": 80,
			"mp": 334,
			"mpperlevel": 50,
			"movespeed": 330,
			"armor": 20.88,
			"armorperlevel": 3.5,
			"spellblock": 30,
			"spellblockperlevel": 0,
			"attackrange": 550,
			"hpregen": 6.508,
			"hpregenperlevel": 0.6,
			"mpregen": 6,
			"mpregenperlevel": 0.8,
			"crit": 0,
			"critperlevel": 0,
			"attackdamage": 53.04,
			"attackdamageperlevel": 3,
			"attackspeedoffset": -0.065,
			"attackspeedperlevel": 2
		}
	}
	""".data(using: .utf8)!
}
