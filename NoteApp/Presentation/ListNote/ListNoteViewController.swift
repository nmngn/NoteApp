//
//  ListNoteViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit

class ListNoteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var model = [ListNoteModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupNavigationButton()
        configView()
        setupData()
    }
    
    func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.tableFooterView = UIView()
            $0.separatorStyle = .none
            $0.registerNibCellFor(type: TitleTableViewCell.self)
            $0.registerNibCellFor(type: ItemTableViewCell.self)
            $0.registerNibCellFor(type: SearchTableViewCell.self)
            $0.keyboardDismissMode = .onDrag
            $0.scrollsToTop = false
        }
    }
    
    func setupData() {
        self.model.removeAll()
        var title = ListNoteModel(type: .title)
        title.title = "Notes"
        title.fontStyle = UIFont.boldSystemFont(ofSize: 18)
        
        let search = ListNoteModel(type: .search)
        
        var item = ListNoteModel(type: .item)

        
        self.model.append(title)
        self.model.append(search)
        self.model.append(item)
        self.model.append(item)
        self.model.append(item)
        self.model.append(item)

        self.tableView.reloadData()
    }
    
    func modelIndexPath(index: IndexPath) -> ListNoteModel {
        return model[index.row]
    }
    
    @IBAction func addFolder(_ sender: UIButton) {
        
    }
    
    @IBAction func addQUickNote(_ sender: UIButton) {
        
    }
}

extension ListNoteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var model: ListNoteModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .title:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell", for: indexPath)
                    as? TitleTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupData(data: model)
            return cell
        case .item:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath)
                    as? ItemTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        case .search:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath)
                    as? SearchTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model: ListNoteModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .item:
            print("0")
        default:
            break
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
