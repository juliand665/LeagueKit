import Foundation

@discardableResult fileprivate func with<T>(_ object: T, do transform: (inout T) throws -> Void) rethrows -> T {
	var copy = object
	try transform(&copy)
	return copy
}

infix operator <-: NilCoalescingPrecedence

@discardableResult public func <- <T>(lhs: T, rhs: (inout T) throws -> Void) rethrows -> T {
	return try with(lhs, do: rhs)
}

infix operator ???: NilCoalescingPrecedence

func ??? <Wrapped>(optional: Wrapped?, error: @autoclosure () -> Error) throws -> Wrapped {
	guard let unwrapped = optional else {
		throw error()
	}
	return unwrapped
}

extension NSError {
	/// Creates an `NSError` object with the specified parameters. (Because the default initializer is terrible.)
	convenience init(code: Int = 0, localizedDescription: String? = nil, localizedRecoverySuggestion: String? = nil) {
		var userInfo: [String: Any] = [:]
		userInfo[NSLocalizedDescriptionKey] = localizedDescription
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = localizedRecoverySuggestion
		self.init(domain: "com.juliand665.LeagueKit", code: code, userInfo: userInfo)
	}
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
