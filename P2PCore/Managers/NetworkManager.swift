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
    
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var sha256: Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(count), &hash)
        }
        return Data(bytes: hash)
    }

}

extension Date {
    
    var ISO8601TimeStamp: String {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df.string(from: self)
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
    
    func makeSignature(url: String, timeStamp: String, requestBody: String) -> String {
        let stringValue = String(format: "%@%@%@%@", url, timeStamp, requestBody, core.signatureKey)
        print("SIGNATURE RAW: \(stringValue)")
        let dataValue = stringValue.data(using: .utf8)!
        let signatureEncoded = dataValue.sha256
        let base64 = signatureEncoded.base64EncodedString()
        return base64
    }
    
    func request<T: Mappable>(_ urlString: String, method: Method = .get, parameters: Any?, complete: @escaping ([T]?, Error?) -> Void) -> URLSessionDataTask {
        return request(urlString, method: method, parameters: parameters, complete: { (JSON, error) in
            if let error = error {
                complete(nil, error)
            } else if let JSON = JSON as? [[String: Any]] {
                let array = JSON.map({ (_json) -> T in
                    return T(json: _json)
                })
                complete(array, nil)
            }
        })
    }
    
    func request<T: Mappable>(_ urlString: String, method: Method = .get, parameters: Any?, complete: @escaping (T?, Error?) -> Void) -> URLSessionDataTask {
        return request(urlString, method: method, parameters: parameters, complete: { (JSON, error) in
            if let error = error {
                complete(nil, error)
            } else if let JSON = JSON as? [String: Any] {
                complete(T(json: JSON), nil)
            }
        })
    }
    
    func request(_ urlString: String, method: Method = .get, parameters: Any?, complete: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask {
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        
        var bodyAsString = ""
        
        let timeStamp = Date().ISO8601TimeStamp
        
        if let parameters = parameters {
            let body = try? JSONSerialization.data(withJSONObject: parameters)
            bodyAsString = String(data: body ?? .init(), encoding: .utf8) ?? ""
            
            request.httpBody = body
        }
        
        let signature = makeSignature(url: urlString, timeStamp: timeStamp, requestBody: bodyAsString)
        
        request.addValue(core.platformId, forHTTPHeaderField: "X-Wallet-PlatformId")
        request.addValue(timeStamp, forHTTPHeaderField: "X-Wallet-Timestamp")
        request.addValue(signature, forHTTPHeaderField: "X-Wallet-Signature")
        
        print("BEGIN NEW REQUEST")
        print("\(method.rawValue) \(urlString)")
        print("SIGNATURE: \(signature)")
        print("BODY\n\n \(bodyAsString)")
        print("Headers\n\n \(String(describing: request.allHTTPHeaderFields))")
        print("END NEW REQUEST\n")
        
        return lowLevelRequest(request, complete: complete)
    }
    
    private func lowLevelRequest(_ request: URLRequest, complete: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask {
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
