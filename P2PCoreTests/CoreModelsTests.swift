//
//  CoreModelsTests.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import XCTest

class CoreModelsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    func testDealModel() {
        
        let json: [String: Any] = [
            "PlatformDealId": "BC477907-D7AA-4497-A2C4-FFFFFB1B441D",
            "DealStateId": "Paid",
            "CreateDate": "2017-08-03T13:23:08.47Z",
            "UpdateDate": "2017-08-03T13:23:17.697Z",
            "ExpireDate": "2017-12-01T13:23:08.47Z",
            "Amount": 1.0000,
            "CurrencyId": 643,
            "PlatformPayerId": "vitaliykuzmenko",
            "PayerCommissionAmount": 0,
            "PlatformBonusAmount": 0,
            "PayerPhoneNumber": "79281234567",
            "PayerCardId": 99,
            "PlatformBeneficiaryId": "alinakuzmenko",
            "BeneficiaryCardId": 98,
            "ShortDescription": "2",
            "FullDescription": "3",
            "DealTypeId": "Deferred"
        ]
        
        let deal = Deal(json: json)
        
        XCTAssertEqual(deal.platformDealId, json["PlatformDealId"] as! String)
        XCTAssertEqual(deal.dealStateId, json["DealStateId"] as! String)
//        XCTAssertEqual(deal.createDate., json["CreateDate"] as! String)
//        XCTAssertEqual(deal.expireDate, json["ExpireDate"] as! String)
//        XCTAssertEqual(deal.updatedate, json["UpdateDate"] as! String)
        XCTAssertEqual(deal.amount, 1)
        XCTAssertEqual(deal.currencyId.rawValue, json["CurrencyId"] as! Int)
        XCTAssertEqual(deal.platformPayerId, json["PlatformPayerId"] as! String)
        XCTAssertEqual(deal.payerCommissionAmount, json["PayerCommissionAmount"] as! NSNumber)
        XCTAssertEqual(deal.platformBonusAmount, json["PlatformBonusAmount"] as! NSNumber)
        XCTAssertEqual(deal.payerPhoneNumber, json["PayerPhoneNumber"] as! String)
        XCTAssertEqual(deal.payerCardId, json["PayerCardId"] as! Int)
        XCTAssertEqual(deal.platformBeneficiaryId, json["PlatformBeneficiaryId"] as! String)
        XCTAssertEqual(deal.beneficiaryCardId, json["BeneficiaryCardId"] as! Int)
        XCTAssertEqual(deal.shortDescription, json["ShortDescription"] as! String)
        XCTAssertEqual(deal.fullDescription, json["FullDescription"] as! String)
        XCTAssertEqual(deal.dealTypeId, json["DealTypeId"] as! String)
    }
    
    func testBankCardModel() {
        
    }
    
}


