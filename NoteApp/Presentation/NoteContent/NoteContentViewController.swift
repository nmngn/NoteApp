//
//  NoteContentViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit
import CoreData

class NoteContentViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var idFolder = ""
    var isLock = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
        self.navigationController?.isNavigationBarHidden = false
        setupRightBarButton()
        setupData()
    }
    
    func setupRightBarButton() {
        let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func doneAction() {
        
    }
    
    func saveData(title: String, content: String, isLock: Bool, idNote: String, time: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: context)!
        let note = NSManagedObject(entity: entity, insertInto: context)
        
        note.setValue(title, forKey: "title")
        note.setValue(content, forKey: "description")
        note.setValue(isLock, forKey: "isLock")
        note.setValue(time, forKey: "dateTime")
        note.setValue(self.idFolder, forKey: "idFolder")
        note.setValue(UUID().uuidString, forKey: "idNote")
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func setupData() {
        timeLabel.text = getCurrentDate()
        textView.delegate = self
    }
}

extension NoteContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
}
