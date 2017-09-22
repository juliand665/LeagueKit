//
//  Extensions.swift
//  LeagueHelper
//
//  Created by Julian Dunskus on 11/07/16.
//  Copyright © 2016 Julian Dunskus. All rights reserved.
//

import Foundation

/// Creates an `NSError` object with the specified parameters
func error(code: Int = 0, localizedDescription: String? = nil, localizedRecoverySuggestion: String? = nil) -> NSError {
	var userInfo: [String: Any] = [:]
	userInfo[NSLocalizedDescriptionKey] = localizedDescription
	userInfo[NSLocalizedRecoverySuggestionErrorKey] = localizedRecoverySuggestion
	return NSError(domain: "com.juliand665.LeagueKit", code: code, userInfo: userInfo)
}

/// synchronously executes an asynchronous method with a completion block using a `DispatchGroup`
public func synchronously(execute method: (@escaping () -> Void) -> Void) {
	let group = DispatchGroup()
	group.enter()
	method(group.leave)
	group.wait()
}

extension String {
    /// Reduces the string to lowercase letters (and spaces).
	/// 
	/// - Parameter allowingSpaces: whether to keep or delete spaces; keeps them by default
	func reducedToSimpleLetters(allowingSpaces: Bool = true) -> String {
		return lowercased().filter { (char: Character) -> Bool in // declaring this type explicitly reduced compile time by a full second…
            char >= "a" && char <= "z" || allowingSpaces && char == " "
        }
	}
	
	/// `"The Black Cleaver".substrings(after: " ")` = `["Black Cleaver", "Cleaver"]`
	func substrings(after splitter: Character) -> [Substring] {
		return indices(of: splitter)
			.map { self[$0...].dropFirst() }
			.filter { !$0.isEmpty }
	}
}

extension Double {
	func rounded(decimalDigits digits: Int) -> Double {
		let power = pow(10, Double(digits))
		return (self * power).rounded() / power
	}
	
	func rounded(significantFigures figures: Int) -> Double {
		let offset = Int(ceil(log10(self)))
		return self.rounded(decimalDigits: figures - offset)
	}
}

extension Collection where Element: Equatable {
	func indices(of item: Element) -> [Index] {
		return zip(indices, self)
			.lazy
			.filter { $0.1 == item }
			.map { $0.0 }
	}
}

// MARK: -
// MARK: Sequence extensions
// these should really be part of the standard library

extension Sequence {
	/// like a combination of `map` and `reduce`, `scan` returns an array of all intermediate results of `reduce`
	///  
	/// e.g. `[1, 2, 3, 4, 5].scan(0, +)` = `[1, 3, 6, 10, 15]` (partial sums)
    func scan<Result>(_ initialResult: Result, _ nextPartialResult: @escaping (Result, Element) throws -> Result) rethrows -> [Result] {
        var result = initialResult
        return try map { element in
            result = try nextPartialResult(result, element)
            return result
        }
    }
}

extension Sequence where SubSequence: Sequence, SubSequence.Element == Element { // this constraint will be unnecessary once all the Sequence constraints are implemented in Swift 4
	/// like reduce, but takes the first element of the array as `initialResult`
	/// 
	/// returns `nil` for `[]`
    func reduce(_ nextPartialResult: @escaping (Element, Element) throws -> Element) rethrows -> Element? {
        var iterator = makeIterator()
        return try iterator.next().map { first in
            return try IteratorSequence(iterator).reduce(first, nextPartialResult)
        }
    }
    
	/// like scan, but takes the first element of the array as `initialResult`.
	/// 
	/// returns `nil` for `[]`
    func scan(_ nextPartialResult: @escaping (Element, Element) throws -> Element) rethrows -> [Element]? {
        var iterator = makeIterator()
        return try iterator.next().map { (first: Element) -> [Element] in
            return try [first] + IteratorSequence(iterator).scan(first, nextPartialResult)
        }
    }
}

// MARK: -
// MARK: Decoding Helpers

precedencegroup AccessPrecedence {
	higherThan: BitwiseShiftPrecedence
	associativity: left
}

infix operator →  : AccessPrecedence
infix operator →? : AccessPrecedence
infix operator →! : AccessPrecedence

extension KeyedDecodingContainer {
	/// decode if present
	static func → <T: Decodable>(container: KeyedDecodingContainer, key: Key) throws -> T? {
		return try container.decodeIfPresent(T.self, forKey: key)
	}
	
	/// decode if present, returning nil upon error
	static func →? <T: Decodable>(container: KeyedDecodingContainer, key: Key) -> T? {
		return (try? container.decodeIfPresent(T.self, forKey: key)) ?? nil // doubly wrapped → singly wrapped
	}
	
	/// decode if present, throwing an error if not present
	static func →! <T: Decodable>(container: KeyedDecodingContainer, key: Key) throws -> T {
		// This is not the same as `decode`, because it doesn't insert a stupid placeholder if the key is not present.
		if let result = try container.decodeIfPresent(T.self, forKey: key) {
			return result
		} else {
			throw DecodingError.valueNotFound(T.self, .init(codingPath: container.codingPath, debugDescription: "Expected value for key \(key)!"))
		}
	}
}

struct CustomKey: CodingKey {
	static func named(_ name: String) -> CustomKey {
		return CustomKey(for: name)
	}
	
	var intValue: Int?
	var stringValue: String
	
	private init(for key: String) {
		stringValue = key
	}
	
	init?(intValue: Int) { return nil }
	
	init?(stringValue: String) { return nil }
}
