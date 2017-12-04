//
//  DealsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 17/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
 
    func deal() -> String {
        return relativeToBase("deal")
    }
    
    func dealPay() -> String {
        return relative(deal(), to: "pay")
    }
    
    func deals() -> String {
        return relativeToApi("deals")
    }
    
    func dealsComplete() -> String {
        return relative(deals(), to: "complete")
    }
    
    func deals(platformDealId: String) -> String {
        return relative(deals(), to: platformDealId)
    }
    
    func dealsComplete(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "complete")
    }
    
    func dealsCancel(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "cancel")
    }
    
    func dealsBeneficiaryCard(platformDealId: String) -> String {
        return relative(deals(platformDealId: platformDealId), to: "beneficiaryCard")
    }
    
    func beneficiariesDeals(_ id: String, pageNumber: Int, itemsPerPage: Int, dealStates: [String]? = nil, searchString: String? = nil) -> String {
        var items: [String] = [
            .init(format: "pageNumber=%d", pageNumber),
            .init(format: "itemsPerPage=%d", itemsPerPage),
        ]
        if let dealStates = dealStates {
            items.append(.init(format: "dealStates=%@", dealStates.joined(separator: ",")))
        }
        
        if let searchString = searchString {
            items.append(.init(format: "searchString=%@", searchString))
        }
        
        return relative(beneficiaries(id), to: "deals")
    }
    
}

@objc public class DealsManager: Manager {

    /// Get Deals
    
    @discardableResult public func getDeals(for beneficiaryId: String, pageNumber: Int, itemsPerPage: Int, dealStates: [String]? = nil, searchString: String? = nil, complete: @escaping (DealsResult?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.beneficiariesDeals(beneficiaryId, pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealStates: dealStates, searchString: searchString), parameters: nil, complete: complete)
    }
    
    /// Create money request for payer
    ///
    /// - Parameters:
    ///   - dealId: Deal identifier in your system
    ///   - payerCardId: Bank card, to which funds will be transferred

    @discardableResult public func create(dealId: String, beneficiaryId: String, payerPaymentToolId: Int = 0, beneficiaryPaymentToolId: Int, amount: NSNumber, currencyId: CurrencyId, shortDescription: String, fullDescription: String, deferPayout: Bool, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        var parameters: [String: Any] = [
            "PlatformDealId": dealId,
            
            "PlatformPayerId": core.payerId,
            "PayerPhoneNumber": core.payerPhoneNumber,
            
            "PlatformBeneficiaryId": beneficiaryId,
            "BeneficiaryPaymentToolId": beneficiaryPaymentToolId,
            
            "Amount": amount,
            "CurrencyId": currencyId.rawValue,
            
            "ShortDescription": shortDescription,
            "FullDescription": fullDescription,
            
            "DeferPayout": deferPayout ? "true" : "false"
        ]
        
        if payerPaymentToolId != 0 {
            parameters["PayerPaymentToolId"] = payerPaymentToolId
        }
        
        return core.networkManager.request(URLComposer.default.deals(), method: .post, parameters: parameters, complete: complete)
    }
    
    /// Complete deal

    @discardableResult public func complete(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsComplete(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
    @discardableResult public func complete(dealIds: [String], paymentToolId: String, complete: @escaping ([Deal]?, Error?) -> Void) -> URLSessionDataTask {
        let parameters: [String: Any] = [
            "PlatformDeals": dealIds,
            "PaymentToolId": paymentToolId
        ]
        return core.networkManager.request(URLComposer.default.dealsComplete(), method: .put, parameters: parameters, complete: complete)
    }
    
    /// Cancel deal
    
    @discardableResult public func cancel(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.dealsCancel(platformDealId: dealId), method: .put, parameters: nil, complete: complete)
    }
    
    /// Get deal status

    @discardableResult public func status(dealId: String, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        return core.networkManager.request(URLComposer.default.deals(platformDealId: dealId), method: .get, parameters: nil, complete: complete)
    }
    
    /// Change bank card in deal.
    /// This action acceptable when deal status one of (Created | PaymentProcessing | PaymentProcessError | Paid | PayoutProcessError)
    ///
    /// - Parameters:
    ///   - autoComplete: Perfrom transaction after the card has been updated

    @discardableResult public func set(paymentToolId: Int, for dealId: String, autoComplete: Bool, complete: @escaping (Deal?, Error?) -> Void) -> URLSessionDataTask {
        let parameters: [String: Any] = [
            "PaymentToolId": paymentToolId,
            "AutoComplete": autoComplete
        ]
        return core.networkManager.request(URLComposer.default.dealsBeneficiaryCard(platformDealId: dealId), method: .put, parameters: parameters, complete: complete)
    }
    
    // Pay deal
    
    public func payRequest(dealId: String, paymentTypeId: String?, redirectToPaymentToolAddition: Bool?, authData: String? = nil, returnUrl: String) -> URLRequest {
        
        let urlString = URLComposer.default.dealPay()
        
        let url = URL(string: urlString)!
        
        let timeStamp = Date().ISO8601TimeStamp
        
        var items: [(key: String, value: String)] = [
            ("PlatformDealId", dealId),
            ("PlatformId", core.platformId),
            ("Timestamp", timeStamp),
            ("ReturnUrl", returnUrl)
        ]
        
        if let paymentTypeId = paymentTypeId {
            items.append(("PaymentTypeId", paymentTypeId))
        }
        
        if let redirectToPaymentToolAddition = redirectToPaymentToolAddition {
            items.append(("RedirectToPaymentToolAddition", redirectToPaymentToolAddition ? "true" : "false"))
        }
        
        if let authData = authData {
            items.append(("AuthData", authData))
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
