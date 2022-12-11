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
    
    var titleFolder = ""
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
        setupNavigationButton()
        configView()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = titleFolder
        if Session.shared.reloadInList {
            getData()
            Session.shared.reloadInList = false
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
        
        let search = ListNoteModel(type: .search)
        var pinText = ListNoteModel(type: .title)
        pinText.title = "Pin"
        pinText.fontTitle = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        var noteText = ListNoteModel(type: .title)
        noteText.title = "Notes"
        noteText.fontTitle = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        self.model.append(search)
        
        let listPin = listNote.filter({$0.value(forKey: "isPin") as? Bool ?? false == true})
        
        let listNormal = listNote.filter({!listPin.contains($0)})
        
        if !listPin.isEmpty && listNormal.isEmpty {
            model.append(pinText)
            for item in listPin {
                model.append(parseToListNote(item: item))
            }
        } else if listPin.isEmpty && !listNormal.isEmpty {
            for item in listNote {
                model.append(parseToListNote(item: item))
            }
        } else if !listPin.isEmpty && !listNormal.isEmpty {
            model.append(pinText)
            for item in listPin {
                model.append(parseToListNote(item: item))
            }
            model.append(noteText)
            for item in listNormal {
                model.append(parseToListNote(item: item))
            }
        }

        self.tableView.reloadData()
    }
    
    func modelIndexPath(index: IndexPath) -> ListNoteModel {
        return model[index.row]
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
        vc.idFolder = self.idFolder
        self.title = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getDataOfNote(id: String, indexPath: IndexPath) {
        let context = self.getContext()
        let fetchNoteRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchNoteRequest.predicate = NSPredicate(format: "idNote = %@", id)
        
        do {
            let results = try context.fetch(fetchNoteRequest)
            if !results.isEmpty, let note = results.first {
                model[indexPath.row] = parseToListNote(item: note)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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
            cell.openSearch = {[ weak self] in
                let vc = SearchViewController.init(nibName: SearchViewController.className, bundle: nil)
                self?.title = ""
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model: ListNoteModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .item:
            if model.isLock {
                let vc = LockNoteViewController.init(nibName: LockNoteViewController.className, bundle: nil)
                vc.dataNote = model
                self.title = ""
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
                vc.dataContent = model
                self.title = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var model: ListNoteModel
        model = modelIndexPath(index: indexPath)
        
        switch model.type {
        case .item:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var pinText = "Pin"
        var lockText = "Lock"
        
        if model[indexPath.row].isPin {
            pinText = "Unpin"
        }
        
        if model[indexPath.row].isLock {
            lockText = "Unlock"
        }
        
        let pinAction = UITableViewRowAction(style: .normal, title: pinText) { [weak self] rowAction, indexPath in
            if pinText == "Pin" {
                self?.pinNote(id: self?.model[indexPath.row].idNote ?? "", isPin: true)
            } else {
                self?.pinNote(id: self?.model[indexPath.row].idNote ?? "", isPin: false)
            }
            self?.getData()
        }
        pinAction.backgroundColor = UIColor(hex: "#f39c12")
        
        let lockAction = UITableViewRowAction(style: .normal, title: lockText) { [weak self] rowAction, indexPath in
            if Session.shared.passwordNote.isEmpty {
                self?.createPassword(actionAfterSetPassword: { [weak self] in
                    self?.lockNote(id: self?.model[indexPath.row].idNote ?? "", isLock: true)
                })
                self?.getDataOfNote(id: self?.model[indexPath.row].idNote ?? "", indexPath: indexPath)
                self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            } else {
                if lockText == "Lock" {
                    self?.lockNote(id: self?.model[indexPath.row].idNote ?? "", isLock: true)
                } else {
                    if let isLock = self?.model[indexPath.row].isLock, isLock {
                        self?.presentAlertUnlock { [weak self] in
                            self?.lockNote(id: self?.model[indexPath.row].idNote ?? "", isLock: false)
                            self?.getDataOfNote(id: self?.model[indexPath.row].idNote ?? "", indexPath: indexPath)
                            self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                        }
                    }
                }
                self?.getDataOfNote(id: self?.model[indexPath.row].idNote ?? "", indexPath: indexPath)
                self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            }
        }
        lockAction.backgroundColor = .lightGray
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { [weak self] rowAction, indexPath in
            if let note = self?.model[indexPath.row] {
                if note.isLock {
                    self?.presentAlertUnlock { [weak self] in
                        self?.tableView.beginUpdates()
                        self?.deleteNote(idNote: (self?.model[indexPath.row].idNote) ?? "")
                        self?.model.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .none)
                        self?.tableView.endUpdates()
                    }
                } else {
                    self?.tableView.beginUpdates()
                    self?.deleteNote(idNote: (self?.model[indexPath.row].idNote) ?? "")
                    self?.model.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .none)
                    self?.tableView.endUpdates()
                }
            }
        }
        deleteAction.backgroundColor = UIColor(red: 1.00, green: 0.15, blue: 0.15, alpha: 0.8)
        
        return [pinAction, lockAction, deleteAction]
    }
}
