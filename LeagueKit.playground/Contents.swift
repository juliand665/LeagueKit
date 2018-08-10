//: # LeagueKit
//: ## Swifty access to League of Legends data
//: ---
//: ### Setup
import Cocoa
import LeagueKit

let client = Client()
let champs = Champions.shared
let items = Items.shared

let group = DispatchGroup()

synchronously(execute: client.updateVersions)
group.enter()
client.update(champs, completion: group.leave)
group.enter()
client.update(items, completion: group.leave)
group.wait()
//: ---
//: ### Testing
let cait = champs.contents["Caitlyn"]!
cait.stats.attackSpeed.value(atLevel: 1)
cait.stats.attackSpeed.value(atLevel: 18)
NSImage(byReferencing: cait.imageURL!)

champs.assets(matchingQuery: "cait", ordering: .byQuality)
