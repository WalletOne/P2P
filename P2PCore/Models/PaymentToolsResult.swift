//
//  PaymentToolsResult.swift
//  P2PCore
//
//  Created by Vitaliy Kuzmenko on 04/12/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class PaymentToolsResult: NSObject, Mappable {
    
    public var paymentTools: [PaymentTool] = []
    
    public var totalCount: Int = 0
    
    public required init(json: [String : Any]) {
        paymentTools = map(json["PaymentTools"], [])
        totalCount = map(json["TotalCount"], 0)
    }
    
}
