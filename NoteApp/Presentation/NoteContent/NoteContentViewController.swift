//
//  NoteContentViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit
import CoreData

class NoteContentViewController: UIViewController {

    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    var dataContent: ListNoteModel?
    
    var idNote = ""
    var idFolder = ""
    var isLock = false
    
    var titleNote = ""
    var contentNote = ""
    var lineCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
        self.navigationController?.isNavigationBarHidden = false
        setupRightBarButton()
        configComponent()
        setupData()
    }
    
    func configComponent() {
        timeLabel.text = getCurrentDate()
        titleTextView.delegate = self
        titleTextView.autocorrectionType = .no
        titleTextView.becomeFirstResponder()
        contentTextView.delegate = self
        contentTextView.autocorrectionType = .no
        contentTextView.isEditable = false
        scrollViewHeightConstraint.constant = 0
    }
    
    func setupData() {
        if let data = self.dataContent {
            timeLabel.text = data.date
            if data.titleNote == "No title" {
                titleTextView.text = ""
            } else {
                titleTextView.text = data.titleNote
            }
            if data.contentNote == "No content" {
                contentTextView.text = ""
            } else {
                contentTextView.text = data.contentNote
            }
            isLock = data.isLock
            idNote = data.idNote
            
            contentTextView.isEditable = true
        }
    }
    
    func setupRightBarButton() {
        let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func touchBackButton() {
        saveData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() {
        saveData()
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveData() {
        if !titleTextView.text.isEmpty && !contentTextView.text.isEmpty {
            getDataToSave(title: titleTextView.text, content: contentTextView.text
                          , isLock: isLock
                          , idNote: !self.idNote.isEmpty ? self.idNote : UUID().uuidString
                          , time: timeLabel.text ?? getCurrentDate())
        } else if titleTextView.text.isEmpty && !contentTextView.text.isEmpty {
            getDataToSave(title: "No title", content: contentTextView.text
                          , isLock: isLock
                          , idNote: !self.idNote.isEmpty ? self.idNote : UUID().uuidString
                          , time: timeLabel.text ?? getCurrentDate())
        } else if !titleTextView.text.isEmpty && contentTextView.text.isEmpty {
            getDataToSave(title: titleTextView.text, content: "No content"
                          , isLock: isLock
                          , idNote: !self.idNote.isEmpty ? self.idNote : UUID().uuidString
                          , time: timeLabel.text ?? getCurrentDate())
        }
    }
    
    func getDataToSave(title: String, content: String, isLock: Bool, idNote: String, time: String) {
        let context = getContext()
        
        let fetchRequest : NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idNote == %@", idNote)
        do {
            let results = try context.fetch(fetchRequest)
            if let note = results.first {
                note.title = title
                note.idNote = idNote
                note.isLock = isLock
                note.dateTime = time
                note.detail = content
                note.idFolder = self.idFolder
            }
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension NoteContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.titleTextView.frame.size.height = self.titleTextView.contentSize.height
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.titleTextView && text == "\n" {
            self.contentTextView.isEditable = true
            self.contentTextView.becomeFirstResponder()
            lineCount += 1
            return false
        }
        
        if textView == self.contentTextView && text == "\n" {
            lineCount += 1
            return true
        }
        
        if lineCount > 20 {
            self.scrollViewHeightConstraint.constant += 8
        }
        
        return true
    }
}
