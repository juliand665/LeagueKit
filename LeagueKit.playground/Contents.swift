//: # LeagueKit
//: ## Swifty access to League of Legends data
//: ---
//: ### Setup
import Cocoa
import LeagueKit

let requester = Requester()
let champs = Champions.shared
let items = Items.shared

let group = DispatchGroup()

synchronously(execute: requester.updateVersions)
group.enter()
requester.update(champs, completion: group.leave)
group.enter()
requester.update(items, completion: group.leave)
group.wait()
//: ---
//: ### Testing
let cait = champs.contents["Caitlyn"]!
cait.stats.attackSpeed.value(atLevel: 1)
cait.stats.attackSpeed.value(atLevel: 18)
