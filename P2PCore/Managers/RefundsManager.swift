//
//  RefundsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 24/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
    
    func payersRefunds(_ id: String, pageNumber: Int, itemsPerPage: Int, dealId: String? = nil) -> String {
        var items: [String] = [
            .init(format: "pageNumber=%d", pageNumber),
            .init(format: "itemsPerPage=%d", itemsPerPage),
            ]
        if let dealId = dealId {
            items.append(.init(format: "dealId=%@", dealId))
        }
        return relative(payers(id), to: "refunds?" + items.joined(separator: "&"))
    }
    
}

@objc public class RefundsManager: Manager {
    
    /// Get all refunds by payer
    
    @discardableResult public func refunds(of payerId: String, pageNumber: Int, itemsPerPage: Int, dealId: String? = nil, complete: @escaping ([RefundsResult]?, Error?) -> Void) -> URLSessionDataTask {
        let url = URLComposer.default.payersRefunds(payerId, pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId)
        return core.networkManager.request(url, method: .get, parameters: nil, complete: complete)
    }
    
}
