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

extension KeyedDecodingContainer {
	
	/// nicer type inference
	subscript<T: Decodable>(key: Key) -> T? {
		// Stupid doubly wrapped optionals make this ugly. Can't chain optionals in this specific constellation ;~;
		if let unwrapped = try? decodeIfPresent(T.self, forKey: key) {
			return unwrapped
		} else {
			return nil
		}
	}
}

extension String {
	
    /// Reduces the string to lowercase letters (and spaces).
	/// 
	/// - Parameter allowingSpaces: whether to keep or delete spaces; keeps them by default
	func reducedToSimpleLetters(allowingSpaces: Bool = true) -> String {
		return lowercased().filter { char in
            char >= "a" && char <= "z" || allowingSpaces && char == " "
        }
	}
	
	/// `"The Black Cleaver".substrings(after: " ")` = `["Black Cleaver", "Cleaver"]`
	func substrings(after splitter: Character) -> [Substring] {
		return indices(of: splitter)
			.map { self[index(after: $0)...] }
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
			.filter { $0.1 == item }
			.map { $0.0 }
	}
}

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

extension Sequence where SubSequence: Sequence { // this constraint will be unnecessary once all the Sequence constraints are implemented in Swift 4
    
    typealias SubElement = SubSequence.Element
    
	/// like reduce, but takes the first element of the array as `initialResult`
	/// 
	/// returns `nil` for `[]`
    func reduce(_ nextPartialResult: @escaping (Element, SubElement) throws -> Element) rethrows -> Element? {
        var iterator = makeIterator()
        return try iterator.next().map { first in
            return try dropFirst().reduce(first, nextPartialResult)
        }
    }
    
	/// like scan, but takes the first element of the array as `initialResult`.
	/// 
	/// returns `nil` for `[]`
    func scan(_ nextPartialResult: @escaping (Element, SubElement) throws -> Element) rethrows -> [Element]? {
        var iterator = makeIterator()
        return try iterator.next().map { (first: Element) -> [Element] in
            return try [first] + dropFirst().scan(first, nextPartialResult)
        }
    }
}
