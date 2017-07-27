//
//  BankCardsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 24/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
    
    func beneficiary() -> String {
        return relativeToBase("beneficiary")
    }
    
    func beneficiaryCard() -> String {
        return relative(beneficiary(), to: "card")
    }
    
    func beneficiaries() -> String {
        return relativeToApi("beneficiaries")
    }
    
    func beneficiaries(_ id: String) -> String {
        return relative(beneficiaries(), to: id)
    }
    
    func beneficiariesCards(_ id: String) -> String {
        return relative(beneficiaries(id), to: "cards")
    }
    
    func beneficiariesCardsCard(_ id: String, card: Int) -> String {
        return relative(beneficiariesCards(id), to: String(card))
    }
    
}

extension String {
    
    var urlEncode: String {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "_.-~")
        return addingPercentEncoding(withAllowedCharacters: set) ?? self
    }
    
}

@objc public class BeneficiariesCardsManager: Manager {
    
    /// Get all cards of beneficiary
    
    @discardableResult public func cards(complete: @escaping ([BankCard]?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCards(core.benificaryId), method: .get, parameters: nil, complete: complete)
    }

    /// Get card of beneficiary by id
    
    @discardableResult public func card(with id: Int, complete: @escaping (BankCard?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCardsCard(core.benificaryId, card: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked card of beneficiary
    
    @discardableResult public func delete(cardWith id: Int, complete: @escaping (BankCard?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCardsCard(core.benificaryId, card: id), method: .delete, parameters: nil, complete: complete)
    }
    
    /// Link new bank card request
    
    public func linkNewCardRequest(returnUrl: String) -> URLRequest {
        
        let url = URL(string: URLComposer.default.beneficiaryCard())!
        
        let timeStamp = Date().ISO8601TimeStamp
        
        var items: [String] = [
            .init(format: "PlatformId=%@", core.platformId),
            .init(format: "PlatformBeneficiaryId=%@", core.benificaryId),
            .init(format: "PhoneNumber=%@", core.benificaryTitle.urlEncode),
            .init(format: "ReturnUrl=%@", returnUrl.urlEncode),
            .init(format: "RedirectToCardAddition=%@", "true"),
            .init(format: "title=%@", core.benificaryTitle)
        ]
        
        let queryStringPre = items.joined(separator: "&")
        //URLComposer.default.beneficiaryCard()
        let signature = core.networkManager.makeSignature(url: "https://dev.walletone.com/p2p/beneficiary/card", timeStamp: timeStamp, requestBody: queryStringPre)
        
        items.append(.init(format: "Signature=%@", signature))
        items.append(.init(format: "Timestamp=%@", timeStamp))
        
        let queryString = items.joined(separator: "&")
        let queryData = queryString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = queryData
        
        return request
    }
    
}
