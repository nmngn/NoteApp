//
//  ListNoteViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit
import CoreData

class ListNoteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteCountLabel: UILabel!
    
    var pullControl = UIRefreshControl()
    
    var idFolder = ""
    var model = [ListNoteModel]()
    var listNote: [NSManagedObject] = [] {
        didSet {
            self.setupData()
        }
    }
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        setupNavigationButton()
        configView()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Session.shared.popToList {
            getData()
            Session.shared.popToList = false
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
        
        let fetchNoteRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchNoteRequest.predicate = NSPredicate(format: "idFolder = %@", self.idFolder)

        do {
            listNote = try managedContext.fetch(fetchNoteRequest)

            for item in listNote {
                self.model.append(parseToListNote(item: item))
            }
            self.noteCountLabel.text = "\(listNote.count) Notes"
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.pullControl.endRefreshing()
    }
    
    func configView() {
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.tableFooterView = UIView()
            $0.separatorStyle = .none
            $0.registerNibCellFor(type: TitleTableViewCell.self)
            $0.registerNibCellFor(type: ItemTableViewCell.self)
            $0.registerNibCellFor(type: SearchTableViewCell.self)
            $0.keyboardDismissMode = .onDrag
            $0.scrollsToTop = true
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
            $0.addSubview(pullControl)
        }
    }
    
    @objc func refresh() {
        self.getData()
    }
    
    func setupData() {
        self.model.removeAll()
        var title = ListNoteModel(type: .title)
        title.title = "Notes"
        title.fontStyle = UIFont.boldSystemFont(ofSize: 18)
        
        let search = ListNoteModel(type: .search)
        
        self.model.append(title)
        self.model.append(search)

        self.tableView.reloadData()
    }
    
    func modelIndexPath(index: IndexPath) -> ListNoteModel {
        return model[index.row]
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
        vc.idFolder = self.idFolder
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteNote(id: String) {
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        request.predicate = NSPredicate(format: "idNote = %@", id)

        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            Session.shared.popToRoot = true
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
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
            cell.setupData(model: model)
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
            let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
            vc.dataContent = model
            vc.idFolder = idFolder
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
            self.deleteNote(id: self.model[indexPath.row].idNote)
            self.model.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)
            self.tableView.endUpdates()
        }
    }

}
