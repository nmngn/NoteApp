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
    var dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        setupData()
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FolderEntity")
        
        do {
            listFolder = try managedContext.fetch(fetchRequest)
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        }
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
        quickFolder.imageFolder = "quick_folder_icon"
        quickFolder.titleFolder = "Quick Note"
        quickFolder.countNote = 0
        
        var folder = HomeModel(type: .folder)
        folder.imageFolder = "folder_icon"
        folder.titleFolder = "Hihi"
        folder.countNote = 1
        
        self.model.append(title)
        self.model.append(search)
        self.model.append(quickFolder)
        self.model.append(otherTitle)
        self.model.append(folder)
        self.tableView.reloadData()
    }
    
    func modelIndexPath(index: IndexPath) -> HomeModel {
        return model[index.row]
    }
    
    @IBAction func addFolder(_ sender: UIButton) {
        
    }
    
    @IBAction func addQUickNote(_ sender: UIButton) {
        
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
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
