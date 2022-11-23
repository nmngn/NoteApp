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
        setupData()
    }
    
    func setupData() {
        timeLabel.text = getCurrentDate()
        titleTextView.delegate = self
        titleTextView.autocorrectionType = .no
        titleTextView.becomeFirstResponder()
        contentTextView.delegate = self
        contentTextView.autocorrectionType = .no
        contentTextView.isEditable = false
        scrollViewHeightConstraint.constant = 0
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
            getDataToSave(title: titleTextView.text, content: contentTextView.text, isLock: isLock, idNote: UUID().uuidString, time: timeLabel.text ?? getCurrentDate())
        } else if titleTextView.text.isEmpty && !contentTextView.text.isEmpty {
            getDataToSave(title: "No title", content: contentTextView.text, isLock: isLock, idNote: UUID().uuidString, time: timeLabel.text ?? getCurrentDate())
        } else if !titleTextView.text.isEmpty && contentTextView.text.isEmpty {
            getDataToSave(title: titleTextView.text, content: "No content", isLock: isLock, idNote: UUID().uuidString, time: timeLabel.text ?? getCurrentDate())
        }
    }
    
    func getDataToSave(title: String, content: String, isLock: Bool, idNote: String, time: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: context)!
        let note = NSManagedObject(entity: entity, insertInto: context)
        
        note.setValue(title, forKey: "title")
        note.setValue(content, forKey: "detail")
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
