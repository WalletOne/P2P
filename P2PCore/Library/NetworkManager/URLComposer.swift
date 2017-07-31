//
//  URLComposer.swift
//  P2PCore
//
//  Created by Vitaliy Kuzmenko on 01/08/16.
//  Copyright © 2016 Wallet One. All rights reserved.
//

import Foundation

/// WARNING! USE EXTENSION FOR FILL URLS

public class URLComposer {
    
    enum Mode {
        case sandbox, product
    }
    
    public static let `default` = URLComposer()
    
    var mode: Mode = .sandbox
    
    var sandboxURL = "https://api.dev.walletone.com/p2p/"
    
    var productURL = "https://api.dev.walletone.com/p2p"
    
    var apiPath = "api/v2/"
    
    var `protocol`: String {
        switch mode {
        case .sandbox:
            return "https"
        case .product:
            return "https"
        }
    }
    
    var baseURL: String {
        switch mode {
        case .sandbox:
            return sandboxURL
        case .product:
            return productURL
        }
    }
    
    var apiURL: String {
        return baseURL + apiPath
    }
    
    class var baseURL: String { return URLComposer.default.baseURL }
    
    // MARK: - Utitlites
    
    func relativeToBase(_ to: String) -> String {
        return relative(baseURL, to: to)
    }
    
    func relativeToApi(_ to: String) -> String {
        return relative(apiURL, to: to)
    }
    
    func relative(_ base: String, to: String) -> String {
        if base.hasSuffix("/") {
            return base + to
        } else {
            return base + "/" + to
        }
    }
    
}

