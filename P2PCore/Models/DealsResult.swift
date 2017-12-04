//
//  DealsResult.swift
//  P2PCore
//
//  Created by Vitaliy Kuzmenko on 04/12/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class DealsResult: NSObject, Mappable {
    
    public var deals: [Deal] = []
    
    public var totalCount: Int = 0
    
    public required init(json: [String : Any]) {
        deals = map(json["Deals"], [])
        totalCount = map(json["TotalCount"], 0)
    }
    
}
