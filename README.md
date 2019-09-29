<p align="center">
	<img width=192px src="GitHub/logo.png" /><br><br>
	<a href="https://swift.org/package-manager/">
		<img alt="Swift Package Manager compatible" src="https://img.shields.io/badge/swift_package_manager-compatible-brightgreen.svg" />
	</a>
	<a href="./LICENSE">
		<img alt="MIT licensed" src="https://img.shields.io/badge/license-MIT-blue.svg" />
	</a>
</p>

# LeagueKit

Swifty access to League of Legends data
***
## Installation

LeagueKit uses the Swift Package Manager. Simply add `.package(url: "https://github.com/juliand665/LeagueKit.git", .branch("master"))` to the `dependencies` in your `Package.swift` file.

If you're using an older version of Xcode (pre-11), there's both a release and a branch with the old, Carthage-compatible version.

## Usage

### Static Data

To get started, update an object manager using the static data client, e.g.:

```swift
let champs = Champions.shared
StaticDataClient.shared.update(champs)
```

Once you've done that, you can access the values and do as you please:

```swift
let cait = champs.contents["Caitlyn"]!
let attackSpeed = cait.stats.attackSpeed.value(atLevel: 10)
let image = NSImage(byReferencing: cait.imageURL)
let results = champs.assets(matchingQuery: "ca")
```

### Dynamic API

The current API for this is pretty limited, but it does cover several endpoints, e.g. the free champion rotation:

```swift
let dynamicClient = DynamicAPIClient(apiKey: myAPIKey, region: .euw)
dynamicClient.send(ChampionRotationRequest()).then { rotation in
	print("free champs:")
	print(rotation.freeChampions
		.map { "• \(champs[$0]!.name)" } // using the static data to find out which name corresponds to which ID
		.joined(separator: "\n")
	)
}
```

