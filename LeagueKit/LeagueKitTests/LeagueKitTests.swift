import XCTest

@testable import LeagueKit

final class LeagueKitTests: XCTestCase {
	let client = Client()
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	func testRequestingNewestVersion() throws {
		XCTAssert(try !client.updateVersions().await().isEmpty)
	}
	
	func testDecodingItems() throws {
		try client.update(Items.shared, forceUpdate: true).await()
	}
	
	func testDecodingChampions() throws {
		try client.update(Champions.shared, forceUpdate: true).await()
	}
	
	func testDecodingRunes() throws {
		try client.update(Runes.shared, forceUpdate: true).await()
	}
	
	func testDecodingAhri() throws {
		do {
			try testRequestingNewestVersion()
			
			let ahri = try client.responseDecoder.decode(Champion.self, from: ahriJSON)
			
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
		} catch {
			dump(error)
			throw error
		}
	}
	
	func testReencodingAhri() throws {
		let ahri = try client.responseDecoder.decode(Champion.self, from: ahriJSON)
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
