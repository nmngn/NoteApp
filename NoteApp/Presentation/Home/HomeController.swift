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
    var listFolder: [NSManagedObject] = [] {
        didSet {
            setupData()
        }
    }
    var listNote: [NSManagedObject] = []
    var dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        getData()
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
                self.model.append(parseToHomeModel(item: item))
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
            $0.scrollsToTop = false
            $0.es.addPullToRefresh { [weak self] in
                self?.getData()
            }
        }
    }
    
    func parseToHomeModel(item: NSManagedObject) -> HomeModel {
        let id = item.value(forKey: "idFolder") as? String ?? ""
        let text = item.value(forKey: "title") as? String ?? ""
        let data = HomeModel(type: .folder, titleFolder: text, id: id)
        return data
    }
    
    
    func setupData() {
        self.model.removeAll()
        var title = HomeModel(type: .title)
        title.title = "Folders"
        title.fontStyle = UIFont.boldSystemFont(ofSize: 18)
        
        let search = HomeModel(type: .search)
        
        var otherTitle = HomeModel(type: .title)
        otherTitle.title = "Other"
        otherTitle.fontStyle = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        var quickFolder = HomeModel(type: .folder)
        quickFolder.idFolder = ""
        quickFolder.imageFolder = "quick_folder_icon"
        quickFolder.titleFolder = "Quick Note"
        quickFolder.countNote = 0
        
        self.model.append(title)
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
                self?.createFolder(folderTitle: text)
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func createFolder(folderTitle: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "FolderEntity", in: context)!
        let folder = NSManagedObject(entity: entity, insertInto: context)
        
        folder.setValue(folderTitle, forKey: "title")
        folder.setValue(UUID().uuidString, forKey: "idFolder")
        
        do {
            try context.save()
            self.tableView.es.startPullToRefresh()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFolder(id: String) {
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolderEntity")
        request.predicate = NSPredicate(format: "idFolder = %@", id)

        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
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
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model: HomeModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .folder:
            let vc = ListNoteViewController.init(nibName: ListNoteViewController.className, bundle: nil)
            vc.navigationItem.title = model.titleFolder
            vc.idFolder = model.idFolder
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
