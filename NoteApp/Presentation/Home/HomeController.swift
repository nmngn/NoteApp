//
//  HomeController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 14/11/2022.
//

import Foundation
import UIKit
import Then
import CoreData
import ESPullToRefresh

class HomeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var model = [HomeModel]()
    var listFolder: [NSManagedObject] = []
    var listNote: [NSManagedObject] = [] {
        didSet {
            setupData()
        }
    }
    var dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        getData()
        if let data = UserDefaults.standard.value(forKey: "password") as? Data {
            Session.shared.passwordNote = data
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Folders"
        if Session.shared.reloadInRoot {
            getData()
            Session.shared.reloadInRoot = false
        }
    }
    
    func getData() {
        dispatchGroup.enter()
        fetchData()
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    func fetchData() {
        let managedContext = getContext()
        
        let fetchFolderRequest = NSFetchRequest<NSManagedObject>(entityName: "FolderEntity")
        let fetchNoteRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        
        do {
            listFolder = try managedContext.fetch(fetchFolderRequest)
            listNote = try managedContext.fetch(fetchNoteRequest)
            
            for item in listFolder {
                var folder = parseToHomeModel(item: item)
                let noteCount = listNote.filter({$0.value(forKey: "idFolder") as! String == item.value(forKey: "idFolder") as! String})
                folder.countNote = noteCount.count
                self.model.append(folder)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.tableView.es.stopPullToRefresh()
    }
    
    func configView() {
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.tableFooterView = UIView()
            $0.separatorStyle = .none
            $0.registerNibCellFor(type: TitleTableViewCell.self)
            $0.registerNibCellFor(type: FolderTableViewCell.self)
            $0.registerNibCellFor(type: SearchTableViewCell.self)
            $0.keyboardDismissMode = .onDrag
            $0.scrollsToTop = true
            $0.es.addPullToRefresh { [weak self] in
                self?.getData()
            }
        }
    }
    
    func setupData() {
        self.model.removeAll()
    
        let search = HomeModel(type: .search)
        
        var otherTitle = HomeModel(type: .title)
        otherTitle.title = "Other"
        otherTitle.fontStyle = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        var quickFolder = HomeModel(type: .folder)
        quickFolder.idFolder = ""
        quickFolder.imageFolder = "quick_folder_icon"
        quickFolder.titleFolder = "Quick Note"
        quickFolder.countNote = listNote.filter({$0.value(forKey: "idFolder") as! String == ""}).count
        
        self.model.append(search)
        self.model.append(quickFolder)
        self.model.append(otherTitle)
        self.tableView.reloadData()
    }
    
    func modelIndexPath(index: IndexPath) -> HomeModel {
        return model[index.row]
    }
    
    @IBAction func addFolder(_ sender: UIButton) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "Create folder", message: "Create new folder", preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let text = textField.text, !text.isEmpty {
                self?.createFolder(folderTitle: text, completion: { [weak self] in
                    self?.getData()
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Folder Title"
            textField = alertTextField
        }
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addQUickNote(_ sender: UIButton) {
        let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
        vc.idFolder = ""
        self.title = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var model: HomeModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .title:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCell", for: indexPath)
                    as? TitleTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupData(data: model)
            return cell
        case .folder:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FolderTableViewCell", for: indexPath)
                    as? FolderTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.setupData(data: model)
            return cell
        case .search:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath)
                    as? SearchTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.openSearch = {[ weak self] in
                let vc = SearchViewController.init(nibName: SearchViewController.className, bundle: nil)
                self?.title = ""
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model: HomeModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .folder:
            let vc = ListNoteViewController.init(nibName: ListNoteViewController.className, bundle: nil)
            vc.titleFolder = model.titleFolder
            vc.idFolder = model.idFolder
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var model: HomeModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .folder:
            if model.idFolder.isEmpty {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.tableView.beginUpdates()
            self.deleteFolder(id: self.model[indexPath.row].idFolder)
            self.model.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }
}
