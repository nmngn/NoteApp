//
//  UITableView+.swift
//  MoneyManager
//
//  Created by Nam Ngây on 05/07/2021.
//

import UIKit
protocol XibTableViewCell {
    static var name: String { get }
    static func registerCellTo(tableView: UITableView)
    static func reusableCellFor(tableView: UITableView, at indexPath: IndexPath) -> Self?
}

extension XibTableViewCell where Self: UITableViewCell {
    static var name: String {
        return String(describing: self).components(separatedBy: ".").last ?? ""
    }
    
    static func registerCellTo(tableView: UITableView) {
        tableView.register(Self.self, forCellReuseIdentifier: name)
    }
    
    static func reusableCellFor(tableView: UITableView, at indexPath: IndexPath) -> Self? {
        return tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as? Self
    }
}

extension UITableViewCell: XibTableViewCell {
}

extension UITableView {
    func registerNibCellFor<T: UITableViewCell>(type: T.Type) {
        let nibName = type.name
        register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
}
