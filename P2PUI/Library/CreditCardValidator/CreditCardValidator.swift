//
//  CreditPaymentToolValidator.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 27/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

public func ==(lhs: CreditPaymentToolValidationType, rhs: CreditPaymentToolValidationType) -> Bool {
    return lhs.name == rhs.name
}

public struct CreditPaymentToolValidationType: Equatable {
    
    public var name: String
    
    public var regex: String
    
    public init(dict: [String: Any]) {
        if let name = dict["name"] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        
        if let regex = dict["regex"] as? String {
            self.regex = regex
        } else {
            self.regex = ""
        }
    }
    
}

public class CreditPaymentToolValidator {
    
    public lazy var types: [CreditPaymentToolValidationType] = {
        var types = [CreditPaymentToolValidationType]()
        for object in CreditPaymentToolValidator.types {
            types.append(CreditPaymentToolValidationType(dict: object))
        }
        return types
    }()
    
    public init() { }
    
    /**
     Get paymentTool type from string
     
     - parameter string: paymentTool number string
     
     - returns: CreditPaymentToolValidationType structure
     */
    public func type(from string: String) -> CreditPaymentToolValidationType? {
        for type in types {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            let numbersString = self.onlyNumbers(string: string)
            if predicate.evaluate(with: numbersString) {
                return type
            }
        }
        return nil
    }
    
    /**
     Validate paymentTool number
     
     - parameter string: paymentTool number string
     
     - returns: true or false
     */
    public func validate(string: String) -> Bool {
        let numbers = self.onlyNumbers(string: string)
        if numbers.characters.count < 9 {
            return false
        }
        
        var reversedString = ""
        let range: Range<String.Index> = numbers.startIndex..<numbers.endIndex
        
        numbers.enumerateSubstrings(in: range, options: [.reverse, .byComposedCharacterSequences]) { (substring, substringRange, enclosingRange, stop) -> () in
            reversedString += substring!
        }
        
        var oddSum = 0, evenSum = 0
        let reversedArray = reversedString.characters
        
        for (i, s) in reversedArray.enumerated() {
            
            let digit = Int(String(s))!
            
            if i % 2 == 0 {
                evenSum += digit
            } else {
                oddSum += digit / 5 + (2 * digit) % 10
            }
        }
        return (oddSum + evenSum) % 10 == 0
    }
    
    /**
     Validate paymentTool number string for type
     
     - parameter string: paymentTool number string
     - parameter type:   CreditPaymentToolValidationType structure
     
     - returns: true or false
     */
    public func validate(string: String, forType type: CreditPaymentToolValidationType) -> Bool {
        return self.type(from: string) == type
    }
    
    public func onlyNumbers(string: String) -> String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = string.components(separatedBy: set)
        return numbers.joined(separator: "")
    }
    
    // MARK: - Loading data
    
    private static let types = [
        [
            "name": "Amex",
            "regex": "^3[47][0-9]{5,}$"
        ], [
            "name": "Visa",
            "regex": "^4\\d{0,}$"
        ], [
            "name": "MasterPaymentTool",
            "regex": "^5[1-5]\\d{0,14}$"
        ], [
            "name": "Maestro",
            "regex": "^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$"
        ], [
            "name": "Diners Club",
            "regex": "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        ], [
            "name": "JCB",
            "regex": "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        ], [
            "name": "Discover",
            "regex": "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        ], [
            "name": "UnionPay",
            "regex": "^62[0-5]\\d{13,16}$"
        ], [
            "name": "Mir",
            "regex": "^22[0-9]{1,14}$"
        ]
    ]
    
}
