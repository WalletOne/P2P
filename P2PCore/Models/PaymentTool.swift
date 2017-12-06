//
//  PaymentTool.swift
//  P2PCore
//
//  Created by Vitaliy Kuzmenko on 04/12/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class PaymentTool: NSObject, Mappable {
    
    public var paymentToolId: Int = 0
    
    public var paymentTypeId: String = ""
    
    public var mask: String = ""
    
    public required init(json: [String : Any]) {
        paymentToolId = map(json["PaymentToolId"], 0)
        paymentTypeId = map(json["PaymentTypeId"], "")
        mask = map(json["Mask"], "")
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let paymentTool = object as? PaymentTool else { return false }
        return paymentTool.paymentToolId == self.paymentToolId && self.paymentToolId != 0
    }
    
}
