//
//  DataStorage.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

class DataStorage: NSObject {
    
    static let `default` = DataStorage()
    
    var deals: [Deal] = []
    
    var employer: Employer!
    
    var freelancer: Freelancer!
    
    var dealRequests: [DealRequest] = []
    
    func dealRequests(for deal: Deal) -> [DealRequest] {
        if let payed = dealRequests.filter({ $0.deal == deal && $0.isPayed }).first {
            return [payed]
        } else {
            return dealRequests.filter({ $0.deal == deal })
        }
    }
    
    func cancel(request: DealRequest) {
        guard let index = dealRequests.index(of: request) else { return }
        self.dealRequests.remove(at: index)
    }
    
}
