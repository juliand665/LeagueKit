//: # LeagueKit
//: ## Swifty access to League of Legends data
//: ---
//: ### Setup
import Cocoa
import LeagueKit

let staticClient = StaticDataClient.shared
let champs = Champions.shared
let items = Items.shared
let runes = Runes.shared

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
NSImage(byReferencing: cait.imageURL!)

let domination = runes.contents[0]
NSImage(byReferencing: domination.imageURL!)
let electrocute = domination.slots[0][0]
NSImage(byReferencing: electrocute.imageURL!)
//: ---
//: ### Searching
champs.assets(matchingQuery: "ca")
items.assets(matchingQuery: "dam", ordering: .byQuality)
//: ---
//: ## Dynamic API
if let apiKey = apiKey {
	let dynamicClient = DynamicAPIClient(apiKey: apiKey, region: .euw)
	
	dynamicClient.send(ChampionRotationRequest()).then { rotation in
		dump(rotation)
	}
}
