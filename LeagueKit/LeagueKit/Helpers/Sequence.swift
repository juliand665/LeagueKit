// Created by Julian Dunskus

import Foundation

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
