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
        return relative(payers(id), to: "tools")
    }
    
    func payersToolsTool(_ id: String, paymentTool: Int) -> String {
        return relative(payersTools(id), to: String(paymentTool))
    }
    
}

@objc public class PayersPaymentToolsManager: Manager {
    
    /// Get all paymentTools of payer
    
    @discardableResult public func paymentTools(complete: @escaping (PaymentToolsResult?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersTools(core.payerId), method: .get, parameters: nil, complete: complete)
    }
    
    /// Get paymentTool of payer by id
    
    @discardableResult public func paymentTool(with id: Int, complete: @escaping (PaymentTool?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersToolsTool(core.payerId, paymentTool: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked paymentTool of payer
    
    @discardableResult public func delete(paymentToolWith id: Int, complete: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.payersToolsTool(core.payerId, paymentTool: id), method: .delete, parameters: nil, complete: complete)
    }
    
        
}
