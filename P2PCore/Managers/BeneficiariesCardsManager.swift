//
//  BankCardsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 24/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
    
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
    
}
