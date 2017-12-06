//
//  UIImageView+Icon.swift
//  P2PUI
//
//  Created by Vitaliy Kuzmenko on 05/12/2017.
//  Copyright © 2017 Wallet One. All rights reserved.
//

import UIKit

fileprivate var imagesRAMCache: [String: UIImage] = [:]

extension UIImageView {
    
    func set(paymentTypeId: String) {
        let format = "https://www.walletone.com/logo/paymenttype/%@.png?type=pt&w=50&h=50"
        let final = String(format: format, paymentTypeId)
        set(url: final, placeholder: nil)
    }
    
    func set(url: String, placeholder: UIImage?) {
        
        self.image = placeholder
        
        guard let _url = URL(string: url) else { return }
        
        if let cachedImage = imagesRAMCache[url] {
            return self.image = cachedImage
        }
        
        var loadedImage: UIImage? = nil
        
        DispatchQueue.global().async {
            do {
                try loadedImage = UIImage(data: Data(contentsOf: _url))
            } catch {
                // fail
            }
            DispatchQueue.main.async {
                if let loadedImage = loadedImage {
                    imagesRAMCache[url] = loadedImage
                }
                self.image = loadedImage ?? placeholder
            }
        }
    }
    
}
