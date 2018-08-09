// Created by Julian Dunskus

import Foundation

#warning("remove this!")

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




extension KeyedDecodingContainer {
	/**
	convenient type-inferring version of `decode(_:forKey:)`
	
	throws an error if key missing
	*/
	func decodeValue<T>(forKey key: Key) throws -> T where T: Decodable {
		return try decode(T.self, forKey: key)
	}
	
	/**
	convenient type-inferring version of `decodeIfPresent(_:forKey:)`
	
	returns nil if key missing
	*/
	func decodeValueIfPresent<T>(forKey key: Key) throws -> T? where T: Decodable {
		return try decodeIfPresent(T.self, forKey: key)
	}
	
	/**
	convenient type-inferring version of `tryToDecode(_:forKey:)`
	
	returns nil on error
	*/
	func tryToDecodeValue<T>(forKey key: Key) -> T? where T: Decodable {
		return try? decode(T.self, forKey: key)
	}
	
	/**
	convenient type-inferring version of `decode(_:forKey:)`
	
	returns nil on error
	*/
	func tryToDecode<T>(_ type: T.Type, forKey key: Key) -> T? where T: Decodable {
		return try? decode(T.self, forKey: key)
	}
}

extension JSONDecoder {
	/// convenient type-inferring version of `decode(_:from:)`
	func decode<T>(from data: Data) throws -> T where T: Decodable {
		return try decode(T.self, from: data)
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
