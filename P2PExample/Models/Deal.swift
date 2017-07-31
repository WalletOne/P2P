//
//  Deal.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

func ==(l: Deal, r: Deal) -> Bool {
    return l.id == r.id
}

class Deal: Equatable {
    
    var id: String = ""
    
    var title: String = ""
    
    var shortDescription: String = ""
    
    var fullDescription: String = ""
    
    var employer: Employer
    
    init(employer: Employer) {
        self.employer = employer
    }
    
}
