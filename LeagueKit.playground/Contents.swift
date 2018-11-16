//: # LeagueKit
//: ## Swifty access to League of Legends data
//: ---
import Cocoa
import LeagueKit
//: ## Static Data
//: ### Setup
let staticClient = StaticDataClient.shared
let champs = Champions.shared
let items = Items.shared
let runes = Runes.shared

// make sure we have up-to-date versions of everything
try [
	staticClient.update(champs),
	staticClient.update(items),
	staticClient.update(runes),
].sequence().await()
//: ---
//: ### Basics
let cait = champs.contents["Caitlyn"]!
cait.stats.attackSpeed.value(atLevel: 1)
cait.stats.attackSpeed.value(atLevel: 18)
NSImage(byReferencing: cait.imageURL)

let domination = runes.contents[0]
NSImage(byReferencing: domination.imageURL)
let electrocute = domination.slots[0][0]
NSImage(byReferencing: electrocute.imageURL)
//: ---
//: ### Searching
champs.assets(matchingQuery: "ca")
items.assets(matchingQuery: "dam", ordering: .byQuality)
//: ---
//: ## Dynamic API
//: Set your api key in `API Key.swift` (in the auxiliary playground sources folder) to experiment with this.
if let apiKey = apiKey {
	let dynamicClient = DynamicAPIClient(apiKey: apiKey, region: .euw)
	
	dynamicClient.send(ChampionRotationRequest()).then { rotation in
		print("free champs:")
		print(rotation.freeChampions
			.map { "• \(champs[$0]!.name)" } // using the static data to find out which name corresponds to which ID
			.joined(separator: "\n")
		)
	}
}
