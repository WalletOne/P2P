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
    
    var payerId: String = ""
    
    var payerTitle: String = ""
    
    var payerPhoneNumber: String = ""
    
    var benificaryId: String = ""
    
    var benificaryTitle: String = ""
    
    var benificaryPhoneNumber: String = ""
    
    /// Manager for working with deals
    lazy var deals: DealsManager = { return .init(self) }()
    public class var deals: DealsManager { return P2PCore.default.deals }
    
    /// Manager for working with beneficiaries paymentTools
    lazy var beneficiariesPaymentTools: BeneficiariesPaymentToolsManager = { return .init(self) }()
    public class var beneficiariesPaymentTools: BeneficiariesPaymentToolsManager { return P2PCore.default.beneficiariesPaymentTools }
    
    /// Manager for working with payers paymentTools
    lazy var payersPaymentTools: PayersPaymentToolsManager = { return .init(self) }()
    public class var payersPaymentTools: PayersPaymentToolsManager { return P2PCore.default.payersPaymentTools }
    
    /// Manager for working with payouts
    lazy var payouts: PayoutsManager = { return .init(self) }()
    public class var payouts: PayoutsManager { return P2PCore.default.payouts }
    
    /// Manager for working with refunds
    lazy var refunds: RefundsManager = { return .init(self) }()
    public class var refunds: RefundsManager { return P2PCore.default.refunds }
    
    lazy var networkManager: NetworkManager = { return .init(self) }()
    
    public class func setPlatform(id: String, signatureKey: String, environment: Environment = .product) {
        URLComposer.default.environment = environment
        P2PCore.default.platformId = id
        P2PCore.default.signatureKey = signatureKey
    }
    
    public class func setPayer(id: String, title: String, phoneNumber: String) {
        P2PCore.default.payerId = id
        P2PCore.default.payerTitle = title
        P2PCore.default.payerPhoneNumber = phoneNumber
    }
    
    public class func setBenificiary(id: String, title: String, phoneNumber: String) {
        P2PCore.default.benificaryId = id
        P2PCore.default.benificaryTitle = title
        P2PCore.default.benificaryPhoneNumber = phoneNumber
    }
    
    public var isPrintDebugEnabled: Bool = false
    
    class public func printDebug(_ value: Any) {
        if P2PCore.default.isPrintDebugEnabled {
            print(value)
        }
    }

}

@objc public class Manager: NSObject {
    
    var core: P2PCore
    
    init(_ core: P2PCore) {
        self.core = core
    }
    
}
