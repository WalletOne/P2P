//
//  BeneficiariesPaymentToolsManager.swift
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
    
    func beneficiaries() -> String {
        return relativeToApi("beneficiaries")
    }
    
    func beneficiaries(_ id: String) -> String {
        return relative(beneficiaries(), to: id)
    }
    
    func beneficiariesTools(_ id: String) -> String {
        return relative(beneficiaries(id), to: "tools")
    }
    
    func beneficiariesToolsTool(_ id: String, card: Int) -> String {
        return relative(beneficiariesTools(id), to: String(card))
    }
    
}

extension String {
    
    var urlEncode: String {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: "_.-~")
        return addingPercentEncoding(withAllowedCharacters: set) ?? self
    }
    
}

@objc public class BeneficiariesPaymentToolsManager: Manager {
    
    /// Get all cards of beneficiary
    
    @discardableResult public func paymentTools(complete: @escaping (PaymentToolsResult?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesTools(core.benificaryId), method: .get, parameters: nil, complete: complete)
    }

    /// Get card of beneficiary by id
    
    @discardableResult public func paymentTool(with id: Int, complete: @escaping (PaymentTool?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesToolsTool(core.benificaryId, card: id), method: .get, parameters: nil, complete: complete)
    }
    
    ///  Delete linked card of beneficiary
    
    @discardableResult public func delete(paymentToolWith id: Int, complete: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesToolsTool(core.benificaryId, card: id), method: .delete, parameters: nil, complete: complete)
    }
    
    /// Link new bank card request
    
    public func addNewPaymentType(returnUrl: String, paymentTypeId: String?, redirectToPaymentToolAddition: Bool?) -> URLRequest {
        
        let urlString = URLComposer.default.beneficiary()
        
        let url = URL(string: urlString)!
        
        let timeStamp = Date().ISO8601TimeStamp
        
        var items: [(key: String, value: String)] = [
            ("PhoneNumber", core.benificaryPhoneNumber),
            ("PlatformBeneficiaryId", core.benificaryId),
            ("PlatformId", core.platformId),
            ("ReturnUrl", returnUrl)
            ("Timestamp", timeStamp),
            ("Title", core.benificaryTitle),
        ]
        
        if let paymentTypeId = paymentTypeId {
            items.append(("PaymentTypeId", paymentTypeId))
        }
        
        if let redirectToPaymentToolAddition = redirectToPaymentToolAddition {
            items.append(("RedirectToPaymentToolAddition", redirectToPaymentToolAddition ? "true" : "false"))
        }
        
        let signature = core.networkManager.makeSignatureForWeb(parameters: items)
        
        items.append(("Signature", signature))
        
        let queryString = items.map({ String(format: "%@=%@", $0.key, $0.value.urlEncode) }).joined(separator: "&")
        
        P2PCore.printDebug(queryString)
        
        let queryData = queryString.data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = queryData
        
        return request
    }
    
}
