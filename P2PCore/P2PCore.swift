//
//  P2PCore.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class P2PCore: NSObject {
    
    static let `default` = P2PCore()
    
    var partnerId: String = ""
    
    var payerId: String = ""
    
    var payerPhoneNumber: String = ""
    
    /// Manager for working with deals (fetch, create, delete, etc.)
    lazy var deals: DealsManager = { return .init(self) }()
    public class var deals: DealsManager { return P2PCore.default.deals }
    
    public class func set(partnerId: String) {
        P2PCore.default.partnerId = partnerId
    }
    
    public class func setPayer(id: String, phoneNumber: String) {
        P2PCore.default.payerId = id
        P2PCore.default.payerId = phoneNumber
    }
}

@objc public class Manager: NSObject {
    
    var core: P2PCore
    
    init(_ core: P2PCore) {
        self.core = core
    }
    
}
