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
        return relativeToBase("beneficiaries")
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
    
    @discardableResult public func cards(of beneficiaryId: String, complete: @escaping ([BankCard]?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCards(beneficiaryId), method: .get, parameters: nil, complete: complete)
    }

    /// Get card of beneficiary by id
    
    @discardableResult public func card(with id: Int, of beneficiaryId: String, complete: @escaping (BankCard?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCardsCard(beneficiaryId, card: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked card of beneficiary
    
    @discardableResult public func delete(cardWith id: Int, of beneficiaryId: String, complete: @escaping (BankCard?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesCardsCard(beneficiaryId, card: id), method: .delete, parameters: nil, complete: complete)
    }
    
    /// Link new bank card request
    
    public func linkNewCardRequest(beneficiaryId: String, phoneNumber: String, title: String? = nil, returnUrl: String) -> URLRequest {
        
        let url = URL(string: URLComposer.default.beneficiaryCard())!
        
        let timeStamp = Date().ISO8601TimeStamp
        
        var items: [String] = [
            .init(format: "PlatformId=%@", core.platformId),
            .init(format: "PlatformBeneficiaryId=%@", beneficiaryId),
            .init(format: "PhoneNumber=%@", phoneNumber.urlEncode),
            .init(format: "ReturnUrl=%@", returnUrl.urlEncode),
            .init(format: "RedirectToCardAddition=%@", "true")
        ]
        
        if let title = title {
            items.append(.init(format: "title=%@", title))
        }
        
        let queryStringPre = items.joined(separator: "&")
        
        let signature = core.networkManager.makeSignature(url: URLComposer.default.beneficiaryCard(), timeStamp: timeStamp, requestBody: queryStringPre)
        
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
