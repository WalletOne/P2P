//
//  CurrencyId.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public enum CurrencyId: Int {
    
    case rub = 643
    
    public var alphabeticCode: String {
        switch self {
        case .rub:
            return "RUB"
        }
    }
    
    public var symbol: String {
        switch self {
        case .rub:
            return "₽"
        }
    }
    
}
