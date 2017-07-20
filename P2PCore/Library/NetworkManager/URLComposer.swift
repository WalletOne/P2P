//
//  URLComposer.swift
//  Locals
//
//  Created by Vitaliy Kuzmenko on 01/08/16.
//  Copyright © 2016 Locals. All rights reserved.
//

import Foundation

/// WARNING! USE EXTENSION FOR FILL URLS

public class URLComposer {
    
    enum Mode {
        case sandbox, product
    }
    
    public static let instance = URLComposer()
    
    var mode: Mode = .product
    
    var sandboxURL = "http://locals.dev.ikitlab.co/"
    
    var productURL = "https://thelocals.ru/"
    
    var apiPath = "api/mobile/"
    
    var `protocol`: String {
        switch mode {
        case .sandbox:
            return "http"
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
    
    class var baseURL: String { return instance.baseURL }
    
    func set(domain: String, subdomain: String) {
        let url = `protocol` + "://" + subdomain + (subdomain.isEmpty ? "" : ".") + domain + "/"
        switch mode {
        case .sandbox:
            sandboxURL = url
        case .product:
            productURL = url
        }
    }
    
    // MARK: - Utitlites
    
    func relativeToBase(_ to: String) -> String {
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

