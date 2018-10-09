// Created by Julian Dunskus

import Foundation

public enum Season: Int, Codable {
	case preseason3 = 0, season3
	case preseason2014, season2014
	case preseason2015, season2015
	case preseason2016, season2016
	case preseason2017, season2017
	case preseason2018, season2018
}

public enum Queue: Int, Codable {
	case custom = 0
	case snowdownShowdown1v1 = 72
	case snowdownShowdown2v2 = 73
	case hexakillSR = 75
	case urf = 76
	case oneForAllMirrorMode = 78
	case urfCoopVsAI = 83
	case hexakillTT = 98
	case aramButchersBridge = 100
	case nemesisDraft = 310
	case blackMarketBrawlers = 313
	case definitelyNotDominion = 317
	case allRandomSR = 325
	case draftPick5v5 = 400
	case rankedSolo5v5 = 420
	case blindPick5v5 = 430
	case rankedFlex5v5 = 440
	case aram5v5 = 450
	case blindPick3v3 = 460
	case rankedFlex3v3 = 470
	case huntOfTheBloodMoon = 600
	case darkStarSingularity = 610
	case clash = 700
	case coopVsAIIntermediateTT = 800
	case coopVsAIIntroTT = 810
	case coopVsAIBeginnerTT = 820
	case coopVsAIIntroSR = 830
	case coopVsAIBeginnerSR = 840
	case coopVsAIIntermediateSR = 850
	case arurf = 900
	case ascension = 910
	case legendOfThePoroKing = 920
	case nexusSiege = 940
	case doomBotsVoting = 950
	case doomBotsStandard = 960
	case starGuardianNormal = 980
	case starGuardianOnslaught = 990
	case projectHunters = 1000
	case snowARURF = 1010
	case oneForAll = 1020
}

public enum GameMode: String, Codable {
	/// classic SR/TT
	case classic = "CLASSIC"
	case dominion = "ODIN"
	case aram = "ARAM"
	case tutorial = "TUTORIAL"
	case urf = "URF"
	case doomBots = "DOOMBOTSTEEMO"
	case oneForAll = "ONEFORALL"
	case ascension = "ASCENSION"
	case snowdownShowdown = "FIRSTBLOOD"
	case legendOfThePoroKing = "KINGPORO"
	case nexusSiege = "SIEGE"
	case huntOfTheBloodMoon = "ASSASSINATE"
	case allRandomSR = "ARSR"
	case darkStarSingularity = "DARKSTAR"
	case starGuardianInvasion = "STARGUARDIAN"
	case projectHunters = "PROJECT"
}

public enum GameType: String, Codable {
	case custom = "CUSTOM_GAME"
	case tutorial = "TUTORIAL_GAME"
	case matched = "MATCHED_GAME"
}

public enum Map: Int, Codable {
	/// old version from before 2014-11-12
	case summonersRiftSummerV1 = 1
	/// old version from before 2014-11-12
	case summonersRiftAutumnV1 = 2
	case provingGrounds = 3
	/// old version from before V5.11 (2015-06-10)
	case twistedTreelineV1 = 4
	case crystalScar = 8
	case twistedTreeline = 10
	case summonersRift = 11
	case howlingAbyss = 12
	/// Howling Abyss reskin from Bilgewater event
	case butchersBridge = 14
	/// Dark Star: Singularity
	case cosmicRuins = 16
	/// Star Guardian Invasion
	case valoranCityPark = 18
	/// PROJECT: Hunters
	case substructure43 = 19
}

public enum Lane: String, Codable {
	case top = "TOP"
	case jungle = "JUNGLE"
	case mid = "MID"
	case bottom = "BOTTOM"
	case none = "NONE"
}

public enum Role: String, Codable {
	case solo = "SOLO"
	case duo = "DUO"
	case duoCarry = "DUO_CARRY"
	case duoSupport = "DUO_SUPPORT"
	case none = "NONE"
}
