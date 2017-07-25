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
    
    /// Manager for working with deals
    lazy var deals: DealsManager = { return .init(self) }()
    public class var deals: DealsManager { return P2PCore.default.deals }
    
    /// Manager for working with beneficiaries cards
    lazy var beneficiariesCards: BeneficiariesCardsManager = { return .init(self) }()
    public class var beneficiariesCards: BeneficiariesCardsManager { return P2PCore.default.beneficiariesCards }
    
    /// Manager for working with payers cards
    lazy var payersCards: PayersCardsManager = { return .init(self) }()
    public class var payersCards: PayersCardsManager { return P2PCore.default.payersCards }
    
    lazy var networkManager: NetworkManager = { return .init(self) }()
    
    public class func setPlatform(id: String, signatureKey: String) {
        P2PCore.default.platformId = id
        P2PCore.default.signatureKey = signatureKey
    }

}

@objc public class Manager: NSObject {
    
    var core: P2PCore
    
    init(_ core: P2PCore) {
        self.core = core
    }
    
}
