//
//  TableStructuredSection.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 30/03/2017.
//  Copyright © 2017 Vitaliy Kuzmenko. All rights reserved.
//

import Foundation

open class StructuredSection {
    
    open var headerTitle: String?
    
    open var footerTitle: String?
    
    open var rows: [Any] = [] {
        didSet {
            count = rows.count
        }
    }
    
    open var count: Int = 0
    
    open var isEmpty: Bool { return rows.isEmpty }
    
    open func append(_ object: Any) {
        rows.append(object)
    }
    
    open func append(contentsOf objects: [Any]) {
        rows.append(contentsOf: objects)
    }
    
    open subscript(index: Int) -> Any {
        get { return rows[index] }
        set(newValue) { rows[index] = newValue }
    }
    
}
