import XCTest

@testable import LeagueKit

final class LeagueKitTests: XCTestCase {
	let client = StaticDataClient()
	let encoder = JSONEncoder()
	let decoder = JSONDecoder()
	
	func testRequestingNewestVersion() throws {
		XCTAssert(try !client.updateVersions().await().isEmpty)
	}
	
	func testDecodingChampions() throws {
		try client.update(Champions.shared, forceUpdate: true).await()
	}
	
	func testDecodingItems() throws {
		try client.update(Items.shared, forceUpdate: true).await()
	}
	
	func testDecodingRunes() throws {
		try client.update(Runes.shared, forceUpdate: true).await()
	}
	
	func testDecodingAhri() throws {
		do {
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
	
	let ahriJSON = try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: LeagueKitTests.self).path(forResource: "ahri.json", ofType: nil)!))
}
