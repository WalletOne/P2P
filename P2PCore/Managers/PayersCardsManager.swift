//
//  BankCardsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 24/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
    
    func payers() -> String {
        return relativeToApi("payers")
    }
    
    func payers(_ id: String) -> String {
        return relative(payers(), to: id)
    }
    
    func payersCards(_ id: String) -> String {
        return relative(payers(id), to: "cards")
    }
    
    func payersCardsCard(_ id: String, card: Int) -> String {
        return relative(payersCards(id), to: String(card))
    }
    
}

@objc public class PayersCardsManager: Manager {
    
    /// Get all cards of payer
    
    @discardableResult public func cards(complete: @escaping ([BankCard]?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersCards(core.payerId), method: .get, parameters: nil, complete: complete)
    }
    
    /// Get card of payer by id
    
    @discardableResult public func card(with id: Int, complete: @escaping (BankCard?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersCardsCard(core.payerId, card: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked card of payer
    
    @discardableResult public func delete(cardWith id: Int, complete: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersCardsCard(core.payerId, card: id), method: .delete, parameters: nil, complete: complete)
    }
    
        
}
