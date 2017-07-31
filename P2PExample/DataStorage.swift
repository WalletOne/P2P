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
    
    func fillTestData() {
        employer = Employer()
        employer.id = NSUUID().uuidString
        employer.title = "Vitaliy Kuzmenko"
        employer.phoneNumber = "79281234567"
        
        freelancer = Freelancer()
        freelancer.id = NSUUID().uuidString
        freelancer.title = "Mark Kuzmenko"
        freelancer.phoneNumber = "79287654321"
    }
    
    func dealRequests(for deal: Deal) -> [DealRequest] {
        return dealRequests.filter({ $0.deal == deal })
    }
    
    func cancel(request: DealRequest) {
        guard let index = dealRequests.index(of: request) else { return }
        self.dealRequests.remove(at: index)
    }
    
}
