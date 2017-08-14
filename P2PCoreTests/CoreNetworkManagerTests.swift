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
        
        let url = URLComposer.default.beneficiariesCards("alinakuzmenko")
        
        let timeStamp = "2017-08-14T12:09:11"
        
        let bodyAsString = ""
        
        let signature = P2PCore.default.networkManager.makeSignature(url: url, timeStamp: timeStamp, requestBody: bodyAsString)
        
        XCTAssertEqual(signature, "I5ioVRCeta6BALmnjGZY+tve6PNmmQSPLnDkpJzP8Zc=")
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

