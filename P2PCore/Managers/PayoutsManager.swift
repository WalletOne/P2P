//
//  PayoutsManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 24/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

extension URLComposer {
    
    func beneficiariesPayouts(_ id: String, pageNumber: Int, itemsPerPage: Int, dealId: String? = nil) -> String {
        var items: [String] = [
            .init(format: "pageNumber=%d", pageNumber),
            .init(format: "itemsPerPage=%d", itemsPerPage),
        ]
        if let dealId = dealId {
            items.append(.init(format: "dealId=%@", dealId))
        }
        return relative(beneficiaries(id), to: "payouts?" + items.joined(separator: "&"))
    }
    
}

@objc public class PayoutsManager: Manager {
    
    /// Get all payouts by beneficiary id
    
    @discardableResult public func payouts(of beneficiaryId: String, pageNumber: Int, itemsPerPage: Int, dealId: String? = nil, complete: @escaping ([PayoutsResult]?, Error?) -> Void) -> URLSessionDataTask {
        let url = URLComposer.default.beneficiariesPayouts(beneficiaryId, pageNumber: pageNumber, itemsPerPage: itemsPerPage, dealId: dealId)
        return core.networkManager.request(url, method: .get, parameters: nil, complete: complete)
    }
    
}
