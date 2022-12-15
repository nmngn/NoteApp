//
//  LockNoteViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 25/11/2022.
//

import UIKit
import CoreData
import LocalAuthentication

class LockNoteViewController: UIViewController {

    var dataNote: ListNoteModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let context = LAContext()
//        var error: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Use Face ID or Touch ID to open this note"
//
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                [weak self] success, authenticationError in
//
//                DispatchQueue.main.async {
//                    if success {
//                        self?.unlockNote()
//                    } else {
// 
//                    }
//                }
//            }
//        } else {
//            
//        }
    }
    
    func getDataOfNote(id: String) {
        let context = self.getContext()
        let fetchNoteRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchNoteRequest.predicate = NSPredicate(format: "idNote = %@", id)
        
        do {
            let results = try context.fetch(fetchNoteRequest)
            if !results.isEmpty, let note = results.first {
                dataNote = parseToListNote(item: note)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func unlockNote() {
        if let dataNote = self.dataNote {
            self.lockNote(id: dataNote.idNote, isLock: !dataNote.isLock)
            self.getDataOfNote(id: dataNote.idNote)
            if dataNote.isLock {
                let vc = NoteContentViewController.init(nibName: NoteContentViewController.className, bundle: nil)
                vc.dataContent = self.dataNote
                self.title = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    @IBAction func unlockAction(_ sender: UIButton) {
        self.presentAlertUnlock(actionAfterUnlockSuccess: { [weak self] in
            self?.unlockNote()
        })
    }
}
