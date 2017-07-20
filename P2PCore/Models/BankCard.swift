//
//  BankCard.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class BankCard: NSObject, Mappable {
    
    public var cardMask: String = ""
    
    public var cardId: Int = 0
    
    public required init(json: [String : Any]) {
        cardMask = map(json["CardMask"], "")
        cardId = map(json["CardId"], 0)
    }
    
}
