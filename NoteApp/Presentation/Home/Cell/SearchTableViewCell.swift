//
//  SearchTableViewCell.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 16/11/2022.
//

import UIKit

class SearchTableViewCell: UITableViewCell, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var openSearch: (() ->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.delegate = self
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        openSearch?()
        return true
    }
    
}
