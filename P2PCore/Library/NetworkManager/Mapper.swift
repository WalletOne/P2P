//
//  Mapper.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public protocol Mappable: NSObjectProtocol {
    init(json: [String: Any])
}

func map(_ object: Any?, _ def: String) -> String {
    return (object as? String) ?? def
}

func map(_ object: Any?, _ def: Int) -> Int {
    return (object as? NSNumber)?.intValue ?? def
}

func map(_ object: Any?, _ def: Float) -> Float {
    return (object as? NSNumber)?.floatValue ?? def
}

func map(_ object: Any?, _ def: Double) -> Double {
    return (object as? NSNumber)?.doubleValue ?? def
}

func map(_ object: Any?, _ def: NSDecimalNumber) -> NSDecimalNumber {
    guard let number = object as? NSNumber else { return def }
    return NSDecimalNumber(decimal: number.decimalValue)
}

func map<T: Mappable>(_ object: Any?, _ def: T) -> T {
    guard let json = object as? [String: Any] else { return def }
    return T(json: json)
}

func map<T: Mappable>(_ object: Any?, _ def: [T]) -> [T] {
    guard let jsonArray = object as? [[String: Any]] else { return def }
    return jsonArray.map({ (json) -> T in
        return map(json, T(json: [:]))
    })
}


func map<T: RawRepresentable>(_ object: Any?, _ def: T) -> T {
    if let raw = object as? T.RawValue {
        return T(rawValue: raw) ?? def
    } else {
        return def
    }
}

func map(_ object: Any?) -> Date? {
    guard let string = object as? String else { return nil }
    
    let formats = [
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ss'.'SSZ",
        "yyyy-MM-dd'T'HH:mm:ss'.'SS",
        "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
        "yyyy-MM-dd'T'HH:mm:ss'.'SSSZ"
    ]
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    for format in formats {
        
        formatter.dateFormat = format
        
        if let date = formatter.date(from: string) {
            return date
        }
    }
    
    return nil
}
