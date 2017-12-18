//
//  URLComposer.swift
//  P2PCore
//
//  Created by Vitaliy Kuzmenko on 01/08/16.
//  Copyright © 2016 Wallet One. All rights reserved.
//

import Foundation

/// WARNING! USE EXTENSION FOR FILL URLS

let currentApiVersion = "3"

public enum Environment: Int {
    case sandbox, product
}

public class URLComposer {
    
    public static let `default` = URLComposer()
    
    public var environment: Environment = .sandbox
    
    var sandboxURL = "https://api.dev.walletone.com/p2p/"
    
    var productURL = "https://api.w1.ru/p2p/"
    
    var apiPath = "api/v%@/"
    
    var `protocol`: String {
        switch environment {
        case .sandbox:
            return "https"
        case .product:
            return "https"
        }
    }
    
    var baseURL: String {
        switch environment {
        case .sandbox:
            return sandboxURL
        case .product:
            return productURL
        }
    }
    
    func apiURL(ver: String) -> String {
        return baseURL + String(format: apiPath, ver)
    }
    
    class var baseURL: String { return URLComposer.default.baseURL }
    
    // MARK: - Utitlites
    
    func relativeToBase(_ to: String) -> String {
        return relative(baseURL, to: to)
    }
    
    func relativeToApi(_ to: String, ver: String = currentApiVersion) -> String {
        return relative(apiURL(ver: ver), to: to)
    }
    
    func relative(_ base: String, to: String) -> String {
        if base.hasSuffix("/") {
            return base + to
        } else {
            return base + "/" + to
        }
    }
    
}

