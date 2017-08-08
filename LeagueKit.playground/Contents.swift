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

group.enter()
requester.update(assets: champs, completion: group.leave)
group.enter()
requester.update(assets: items, completion: group.leave)
group.wait()
//: ---
//: ### Testing
let cait = champs.assets["Caitlyn"]!
cait.stats.attackSpeed.value(atLevel: 1)
cait.stats.attackSpeed.value(atLevel: 18)









