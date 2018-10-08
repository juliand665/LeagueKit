//: # LeagueKit
//: ## Swifty access to League of Legends data
//: ---
//: ### Setup
import Cocoa
import LeagueKit

let client = Client.shared
let champs = Champions.shared
let items = Items.shared
let runes = Runes.shared

try [
	client.update(champs),
	client.update(items),
	client.update(runes),
].sequence().await()
//: ---
//: ### Basics
let cait = champs.contents["Caitlyn"]!
cait.stats.attackSpeed.value(atLevel: 1)
cait.stats.attackSpeed.value(atLevel: 18)
NSImage(byReferencing: cait.imageURL!)

let electrocute = runes.contents[0].slots[0][0]
NSImage(byReferencing: electrocute.imageURL!)
//: ---
//: ### Searching
champs.assets(matchingQuery: "ca")
items.assets(matchingQuery: "dam", ordering: .byQuality)
