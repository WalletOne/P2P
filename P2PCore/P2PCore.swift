//
//  P2PCore.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

@objc public class P2PCore: NSObject {
    
    public static let `default` = P2PCore()
    
    var platformId: String = ""
    
    var signatureKey: String = ""
    
    var userId: String = ""
    
    /// Manager for working with deals (fetch, create, delete, etc.)
    lazy var deals: DealsManager = { return .init(self) }()
    public class var deals: DealsManager { return P2PCore.default.deals }
    
    lazy var networkManager: NetworkManager = { return .init(self) }()
    
    public class func setPlatform(id: String, signatureKey: String) {
        P2PCore.default.platformId = id
        P2PCore.default.signatureKey = signatureKey
    }
    
    public class func setUser(_ id: String) {
        P2PCore.default.userId = id
    }

}

@objc public class Manager: NSObject {
    
    var core: P2PCore
    
    init(_ core: P2PCore) {
        self.core = core
    }
    
}