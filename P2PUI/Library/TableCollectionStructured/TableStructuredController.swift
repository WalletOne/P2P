//
//  TableStructuredViewController.swift
//  TableCollectionStructured
//
//  Created by Vitaliy Kuzmenko on 06/10/16.
//  Copyright © 2016 Vitaliy Kuzmenko. All rights reserved.
//

import UIKit

public protocol TableStructuredViewController: class {
    var tableView: UITableView! { get set }
}

open class TableStructuredController<ViewController: TableStructuredViewController>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet open weak var tableView: UITableView!
    
    open weak var vc: ViewController!
    
    open var tableStructure: [StructuredSection] = []
    
    public convenience init(vc: ViewController) {
        self.init()
        tableView = vc.tableView
        tableView.dataSource = self
        tableView.delegate = self
        self.vc = vc
        
        configureTableView()
    }
    
    open func indexPath(for object: Any) -> IndexPath? {
        var _section = 0
        for section in tableStructure {
            var row = 0
            for _object in section.rows {
                if let _s = _object as? String, let s = object as? String, _s == s {
                    return IndexPath(row: row, section: _section)
                } else if object as AnyObject === _object as AnyObject {
                    return IndexPath(row: row, section: _section)
                }
                row += 1
            }
            _section += 1
        }
        return nil
    }
    
    open func isSafe(indexPath: IndexPath) -> Bool {
        if tableStructure.isEmpty {
            return false
        } else if tableStructure.count - 1 >= indexPath.section {
            if tableStructure[indexPath.section].isEmpty {
                return false
            } else if tableStructure[indexPath.section].count - 1 >= indexPath.row {
                return true
            }
        }
        return false
    }
    
    open func object(at indexPath: IndexPath) -> Any {
        return tableStructure[indexPath.section][indexPath.row]
    }
    
    open func beginBuilding() {
        tableStructure = []
    }
    
    open func newSection() -> StructuredSection {
        return StructuredSection()
    }
    
    open func append(section: inout StructuredSection) {
        tableStructure.append(section)
        section = StructuredSection()
    }
    
    open func configureTableView() {
        tableView.tableFooterView = UIView()
    }
    
    open func buildTableStructure(reloadData: Bool) {
        if reloadData {
            tableView?.reloadData()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.object(at: indexPath)
        guard let identifier = self.tableView(tableView, reuseIdentifierFor: object) else {
            assert(false, "Reuse identifier for this object is not configured in tableView(_:reuseIdentifierFor:)")
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)!
        self.tableView(tableView, configure: cell, for: object, at: indexPath)
        return cell
    }
    
    open func tableView(_ tableView: UITableView, reuseIdentifierFor object: Any) -> String? {
        var identifier: String?
        if let object = object as? String {
            identifier = object
        }
        return identifier
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section].headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableStructure[section].footerTitle
    }
    
    open func tableView(_ tableView: UITableView, configure cell: UITableViewCell, for object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.tableView(tableView, willDisplay: cell, for: object)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, for object: Any) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let object = self.object(at: indexPath)
        return rowHeight(forObject: object)
    }
    
    open func rowHeight(forIdentifier identifier: String) -> CGFloat {
        return tableView.rowHeight
    }
    
    open func rowHeight(forObject object: Any) -> CGFloat {
        if let object = object as? String {
            return rowHeight(forIdentifier: object)
        }
        return tableView.rowHeight
    }
    
    open var automaticallyDeselect: Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if automaticallyDeselect {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell!.reuseIdentifier!
        let object = self.object(at: indexPath)
        
        self.tableView(tableView, didSelectCellWith: identifier, object: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectCellWith identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if automaticallyDeselect {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        let cell = tableView.cellForRow(at: indexPath)
        let identifier = cell!.reuseIdentifier!
        let object = self.object(at: indexPath)
        self.tableView(tableView, didDeselectCellWith: identifier, object: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectCellWith identifier: String, object: Any, at indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let object = self.object(at: indexPath)
        return self.tableView(tableView, canEditRowWith: object, at: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowWith object: Any, at indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let object = self.object(at: indexPath)
        self.tableView(tableView, commit: editingStyle, for: object, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, for object: Any, forRowAt indexPath: IndexPath) {
        
    }
    
    open func reloadRows(objects: [Any]) {
        
        var indexPaths: [IndexPath] = []
        for object in objects {
            if let indexPath = self.indexPath(for: object) {
                indexPaths.append(indexPath)
            }
        }
        
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
}



