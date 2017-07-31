//
//  Freelancer.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 31/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation

func ==(l: Freelancer, r: Freelancer) -> Bool {
    return l.id == r.id
}

class Freelancer: Equatable {
    
    var id: String = ""
    
    var title: String = ""
    
    var phoneNumber: String = ""
    
}
