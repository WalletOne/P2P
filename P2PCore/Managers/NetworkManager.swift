//
//  NetworkManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation
import CCommonCrypto

let errorDomain = "com.walletone.ios.P2PCore.error"

public let P2PResponseStringKey = "P2PResponseStringKey"
public let P2PResponseErrorCodeKey = "P2PResponseErrorCodeKey"

extension NSError {
    static let missingDataObject = NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("MISSING_RESPONSE_DATA_OBJECT", comment: "")])
    static let jsonParsingError = NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("JSON_PARSING_ERROR", comment: "")])
    static let dataStringError = NSError(domain: errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("DATA_STRING_ERROR", comment: "")])
}

extension Data {
    
    // https://stackoverflow.com/questions/25248598/importing-commoncrypto-in-a-swift-framework
    
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }

}

class NetworkManager: Manager {
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTasks: [URLSessionDataTask] = []
    
    func makeSignature(url: String, timeStamp: Date, requestBody: String) -> String {
        
        let format = String("%@%@%@%@", 
        
        return ""
    }
    
    func request(_ url: String, method: Method = .get, parameters: [String: Any] = [:], complete: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let dataTask = defaultSession.dataTask(with: request) { data, response, error in
            if let error = error {
                complete(nil, error)
            } else if let response = response {
                DispatchQueue.main.async {
                    self.process(response: response, data: data, error: error, complete: complete)
                }
            }
        }
        dataTasks.append(dataTask)
        
        dataTask.resume()
        
        return dataTask
    }
    
    func process(response: URLResponse, data: Data?, error: Error?, complete: @escaping (Any?, Error?) -> Void) {
        guard let response = response as? HTTPURLResponse else { return complete(nil, nil) }
        guard let data = data else { return complete(nil, NSError.missingDataObject) }
        guard let stringValue = String(data: data, encoding: .utf8) else { return complete(nil, NSError.dataStringError) }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return complete(nil, NSError.jsonParsingError) }
        switch response.statusCode {
        case 200...226:
            complete(json, nil)
        default:
            guard let errorJson = json as? [String: String] else {
                let userInfo: [AnyHashable: Any] = [
                    P2PResponseErrorCodeKey: "IS_NOT_NSDICTIONARY",
                    NSLocalizedDescriptionKey: NSLocalizedString("IS_NOT_NSDICTIONARY", comment: ""),
                    P2PResponseStringKey: stringValue
                ]
                let error = NSError(domain: errorDomain, code: 0, userInfo: userInfo)
                return complete(nil, error)
            }
            let errorCode = errorJson["Error"] ?? "UNKNOWN"
            let errorDescription = errorJson["ErrorDescription"] ?? "UNKNOWN"
            let userInfo: [AnyHashable: Any] = [
                P2PResponseErrorCodeKey: errorCode,
                NSLocalizedDescriptionKey: errorDescription,
                P2PResponseStringKey: stringValue
            ]
            complete(nil, NSError(domain: errorDomain, code: 0, userInfo: userInfo))
        }
    }
    
}
