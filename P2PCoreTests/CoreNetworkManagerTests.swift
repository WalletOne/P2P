//
//  P2PCoreTestsNetworkManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 03/08/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import XCTest

class CoreNetworkManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        P2PCore.setPlatform(id: "testplatform", signatureKey: "TestPlatformSignatureKey")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApiSignatureBuilding() {
        
        let url = URLComposer.default.deals()
        
        let timeStamp = "2017-08-03T12:59:54"
        
        let bodyAsString = "{\"PlatformPayerId\":\"vitaliykuzmenko\",\"ShortDescription\":\"2\",\"Amount\":1,\"PayerPhoneNumber\":\"79281234567\",\"CurrencyId\":643,\"DeferPayout\":\"true\",\"PayerCardId\":99,\"FullDescription\":\"\",\"PlatformDealId\":\"8870B45D-FCEF-4572-AEA4-19FD3603F4D9\",\"BeneficiaryCardId\":103,\"PlatformBeneficiaryId\":\"alinakuzmenko\"}"
        
        let signature = P2PCore.default.networkManager.makeSignature(url: url, timeStamp: timeStamp, requestBody: bodyAsString)
        
        XCTAssertEqual(signature, "eAU0l/KsX9nJskrqPOJ4Vw99fs6NwRSAplKueGUa0nQ=")
    }
    
    func testWebViewSignature() {
        let timestamp = "2017-08-03T13:08:15"
        
        let items: [(key: String, value: String)] = [
            ("PhoneNumber", "79287654321"),
            ("PlatformBeneficiaryId", "alinakuzmenko"),
            ("PlatformId", "testplatform"),
            ("RedirectToCardAddition", "true"),
            ("ReturnUrl", "http://p2p-success-link-new-card"),
            ("Timestamp", timestamp),
            ("Title", "Alina Kuzmenko"),
        ]
        
        let signature = P2PCore.default.networkManager.makeSignatureForWeb(parameters: items)
        
        XCTAssertEqual(signature, "Mltf/M8LieoFmi8urPz3qZQfIl36xGZ0P7bCQavGxnU=")
    }
    
}

