//
//  NetworkManager.swift
//  P2P_iOS
//
//  Created by Vitaliy Kuzmenko on 20/07/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import Foundation
import CryptoSwift

let kP2PErrorDomain = "com.walletone.ios.P2PCore.error"

public let P2PResponseStringKey = "P2PResponseStringKey"
public let P2PResponseErrorCodeKey = "P2PResponseErrorCodeKey"

extension NSError {
    static let missingDataObject = NSError(domain: kP2PErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("MISSING_RESPONSE_DATA_OBJECT", comment: "")])
    static let jsonParsingError = NSError(domain: kP2PErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("JSON_PARSING_ERROR", comment: "")])
    static let dataStringError = NSError(domain: kP2PErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("DATA_STRING_ERROR", comment: "")])
    
    class public func error(_ error: String) -> NSError {
        return NSError(domain: kP2PErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: error])
    }
}

extension Date {
    
    var ISO8601TimeStamp: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: self)
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
        let dataValue = stringValue.data(using: .utf8)!
        let signatureEncoded = dataValue.sha256()
        let base64 = signatureEncoded.base64EncodedString()
        return base64
    }
    
    func makeSignatureForWeb(parameters: [(key: String, value: String)]) -> String {

        let array = parameters.sorted(by: { (l, r) -> Bool in
            return l.key < r.key
        })
        
        let stringValue = array.map({ $0.value }).joined() + core.signatureKey
        
        P2PCore.printDebug(stringValue)
        
        let dataValue = stringValue.data(using: .utf8)!
        let signatureEncoded = dataValue.sha256()
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
    
    func request(_ urlString: String, method: Method = .get, parameters: Any?, complete: @escaping (Error?) -> Void) -> URLSessionDataTask {
        return request(urlString, method: method, parameters: parameters, complete: { (JSON, error) in
            complete(error)
        })
    }
    
    func request(_ urlString: String, method: Method = .get, parameters: Any?, complete: @escaping (Any?, Error?) -> Void) -> URLSessionDataTask {
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var bodyAsString = ""
        
        let timeStamp = Date().ISO8601TimeStamp
        
        if let parameters = parameters {
            let body = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            bodyAsString = String(data: body ?? .init(), encoding: .utf8) ?? ""
            
            request.httpBody = bodyAsString.data(using: .utf8)
        }
        
        let signature = makeSignature(url: urlString, timeStamp: timeStamp, requestBody: bodyAsString)
        
        request.addValue(core.platformId, forHTTPHeaderField: "X-Wallet-PlatformId")
        request.addValue(timeStamp, forHTTPHeaderField: "X-Wallet-Timestamp")
        request.addValue(signature, forHTTPHeaderField: "X-Wallet-Signature")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        P2PCore.printDebug("=======")
        P2PCore.printDebug("BEGIN NEW REQUEST")
        P2PCore.printDebug("\(request.httpMethod!) \(urlString)")
        P2PCore.printDebug("BODY:\n\(bodyAsString)")
        P2PCore.printDebug("Headers:\n\(String(describing: request.allHTTPHeaderFields ?? [:]))\n")
        P2PCore.printDebug("END NEW REQUEST\n")
        P2PCore.printDebug("=======")
        
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
        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        switch response.statusCode {
        case 200...226:
            complete(json ?? stringValue, nil)
        default:
            guard let errorJson = json as? [String: String] else {
                let userInfo: [String: Any] = [
                    P2PResponseErrorCodeKey: "IS_NOT_NSDICTIONARY",
                    NSLocalizedDescriptionKey: NSLocalizedString("IS_NOT_NSDICTIONARY", comment: ""),
                    P2PResponseStringKey: stringValue
                ]
                let error = NSError(domain: kP2PErrorDomain, code: 0, userInfo: userInfo)
                return complete(nil, error)
            }
            let errorCode = errorJson["Error"] ?? "UNKNOWN"
            let errorDescription = errorJson["ErrorDescription"] ?? errorJson["Message"] ?? "UNKNOWN"
            let userInfo: [String: Any] = [
                P2PResponseErrorCodeKey: errorCode,
                NSLocalizedDescriptionKey: errorDescription,
                P2PResponseStringKey: stringValue
            ]
            complete(nil, NSError(domain: kP2PErrorDomain, code: 0, userInfo: userInfo))
        }
    }
    
}
