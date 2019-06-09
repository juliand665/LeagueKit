import XCTest

@testable import LeagueKit
import Promise

extension Future {
	func expect(file: StaticString = #file, line: Int = #line, _ assertion: @escaping (Value) throws -> Bool) -> XCTestExpectation {
		let expectation = XCTestExpectation(description: "future assertion")
		self.then { value in 
			do {
				if try assertion(value) {
					expectation.fulfill()
				} else {
					XCTFail("expected assertion failed! \(file):\(line)")
				}
			} catch {
				XCTFail("expected assertion errored! \(file):\(line)")
			}
		}
		self.catch { error in
			XCTFail("error while awaiting expectation! \(file):\(line)")
		}
		return expectation
	}
}

final class LeagueKitTests: XCTestCase {
	let client = StaticDataClient()
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	static let allTests = [
		("requesting the newest version", testRequestingNewestVersion),
		("requesting & decoding champions", testRequestingNewestVersion),
		("requesting & decoding items", testRequestingNewestVersion),
		("requesting & decoding runes", testRequestingNewestVersion),
		("decoding & checking ahri", testDecodingAhri),
		("de- & re-encoding ahri", testReencodingAhri),
	]
	
	func expect<Value>(on future: Future<Value>, timeout: TimeInterval = 5, file: StaticString = #file, line: Int = #line, _ assertion: @escaping (Value) throws -> Bool) {
		let expectation = future.expect(file: file, line: line, assertion)
		wait(for: [expectation], timeout: timeout)
	}
	
	func expectSuccess<Value>(of future: Future<Value>, timeout: TimeInterval = 5, file: StaticString = #file, line: Int = #line) {
		expect(on: future, timeout: timeout) { _ in true }
	}
	
	func testRequestingNewestVersion() throws {
		expect(on: client.updateVersions()) { !$0.isEmpty }
	}
	
	func testDecodingChampions() throws {
		expectSuccess(of: client.update(Champions.shared, forceUpdate: true))
	}
	
	func testDecodingItems() throws {
		expectSuccess(of: client.update(Items.shared, forceUpdate: true))
	}
	
	func testDecodingRunes() throws {
		expectSuccess(of: client.update(Runes.shared, forceUpdate: true))
	}
	
	func testDecodingAhri() throws {
		try testRequestingNewestVersion()
		
		let ahri = try client.responseDecoder.decode(Champion.self, from: ahriJSON)
		
		XCTAssert(ahri.name == "Ahri")
		
		XCTAssertNotNil(NSImage(contentsOf: ahri.imageURL))
		
		XCTAssertEqual(330, ahri.stats.movementSpeed)
		XCTAssertEqual(550, ahri.stats.attackRange)
		
		func checkStat<Stat: ScalingStat>(expecting expected: Double, atLevel level: Int, for path: KeyPath<Champion.Stats, Stat>) {
			XCTAssertEqual(expected, ahri.stats[keyPath: path].value(atLevel: level).rounded(significantFigures: 3))
		}
		
		checkStat(expecting: 592,	atLevel: 2, for: \.health.max)
		checkStat(expecting: 7.39,	atLevel: 3, for: \.health.regen)
		checkStat(expecting: 475,	atLevel: 4, for: \.mana.max)
		checkStat(expecting: 10.5,	atLevel: 5, for: \.mana.regen)
		checkStat(expecting: 34.7,	atLevel: 6, for: \.armor)
		checkStat(expecting: 32.4,	atLevel: 7, for: \.magicResist)
		checkStat(expecting: 70.4,	atLevel: 8, for: \.attackDamage)
		checkStat(expecting: 0.758,	atLevel: 9, for: \.attackSpeed)
	}
	
	func testReencodingAhri() throws {
		let ahri = try client.responseDecoder.decode(Champion.self, from: ahriJSON)
		let reencoded = try encoder.encode(ahri)
		_ = try decoder.decode(Champion.self, from: reencoded)
	}
}

let ahriJSON = """
{
	"version": "8.23.1",
	"id": "Ahri",
	"key": "103",
	"name": "Ahri",
	"title": "the Nine-Tailed Fox",
	"blurb": "Innately connected to the latent power of Runeterra, Ahri is a vastaya who can reshape magic into orbs of raw energy. She revels in toying with her prey by manipulating their emotions before devouring their life essence. Despite her predatory nature...",
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
		"hp": 526,
		"hpperlevel": 92,
		"mp": 418,
		"mpperlevel": 25,
		"movespeed": 330,
		"armor": 20.88,
		"armorperlevel": 3.5,
		"spellblock": 30,
		"spellblockperlevel": 0.5,
		"attackrange": 550,
		"hpregen": 6.5,
		"hpregenperlevel": 0.6,
		"mpregen": 8,
		"mpregenperlevel": 0.8,
		"crit": 0,
		"critperlevel": 0,
		"attackdamage": 53.04,
		"attackdamageperlevel": 3,
		"attackspeedperlevel": 2,
		"attackspeed": 0.668
	}
}
""".data(using: .utf8)!
