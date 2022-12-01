//
//  SearchViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 28/11/2022.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var searchBar = UISearchBar()
    var model = [ListNoteModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBar()
        configView()
    }
    
    func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.tableFooterView = UIView()
            $0.separatorStyle = .none
            $0.registerNibCellFor(type: ItemTableViewCell.self)
            $0.keyboardDismissMode = .onDrag
            $0.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        }
    }
    
    func setupBar() {
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.titleView = searchBar
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        let button = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = button
    }

    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as?
                ItemTableViewCell else {return UITableViewCell()}
        cell.selectionStyle = .none
        cell.setupData(model: self.model[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
        vc.dataContent = model[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let context = getContext()
            let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            
            do {
                let result = try context.fetch(request)
                for object in result {
                    self.model.append(parseToListNote(item: object))
                }
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        } else {
            self.model.removeAll()
        }
        self.tableView.reloadData()
    }
}
