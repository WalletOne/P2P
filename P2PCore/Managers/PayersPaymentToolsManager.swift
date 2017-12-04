//
//  PayersPaymentToolsManager.swift
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
    
    func payersTools(_ id: String) -> String {
        return relative(payers(id), to: "tool")
    }
    
    func payersToolsTool(_ id: String, card: Int) -> String {
        return relative(payersTools(id), to: String(card))
    }
    
}

@objc public class PayersPaymentToolsManager: Manager {
    
    /// Get all cards of payer
    
    @discardableResult public func paymentTools(complete: @escaping (PaymentToolsResult?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersTools(core.payerId), method: .get, parameters: nil, complete: complete)
    }
    
    /// Get card of payer by id
    
    @discardableResult public func paymentTool(with id: Int, complete: @escaping (PaymentTool?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersToolsTool(core.payerId, card: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked card of payer
    
    @discardableResult public func delete(paymentToolWith id: Int, complete: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersToolsTool(core.payerId, card: id), method: .delete, parameters: nil, complete: complete)
    }
    
        
}
