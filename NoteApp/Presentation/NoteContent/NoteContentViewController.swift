//
//  NoteContentViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit
import CoreData
import Toast_Swift

class NoteContentViewController: UIViewController {

    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    var dataContent: ListNoteModel?
    
    var idNote = ""
    var idFolder = ""
    var isLock = false
    var isPin = false
    
    var titleNote = ""
    var contentNote = ""
    var lineCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
        configComponent()
        setupData()
        countdownView.isHidden = true
        if #available(iOS 14.0, *) {
            setupRightBarButton()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.viewControllers.removeAll(where: {$0 is LockNoteViewController})
    }
    
    func configComponent() {
        timeLabel.text = getCurrentDate()
        titleTextView.delegate = self
        titleTextView.autocorrectionType = .no
        titleTextView.becomeFirstResponder()
        
        contentTextView.delegate = self
        contentTextView.autocorrectionType = .no
        contentTextView.isEditable = false
        
        scrollView.keyboardDismissMode = .onDrag
        
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
            isPin = data.isPin
            idFolder = data.idFolder
            
            contentTextView.isEditable = true
        }
    }
    
    @available(iOS 14.0, *)
    func setupRightBarButton() {
        let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain , target: self, action: #selector(doneAction))
        let setting = UIBarButtonItem(image: UIImage(named: "icon_setting"), style: .plain, target: self, action: #selector(openSetting))
        let timer = UIBarButtonItem(image: self.countdownView.isHidden ? UIImage(named: "ic_time") : UIImage(named: "ic_time_2"), style: .plain, target: self, action: self.countdownView.isHidden ? #selector(setTimer) : nil)
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, setting, timer]
    }
    
    override func touchBackButton() {
        saveData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() {
        saveData()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setTimer() {
        let vc = SetTimerViewController.init(nibName: SetTimerViewController.className, bundle: nil)
        vc.timeChoose = { [weak self] hour, min, sec in
            self?.countdownView.isHidden = false
            self?.countdownLabel.text = "\(hour)H \(min)M \(sec)S"
            if #available(iOS 14.0, *) {
                self?.setupRightBarButton()
            } else {
                // Fallback on earlier versions
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func openSetting() {
        let vc = SettingNoteViewController.init(nibName: SettingNoteViewController.className, bundle: nil)
        vc.delegate = self
        vc.model = dataContent
        self.present(vc, animated: true, completion: nil)
    }
    
    func saveData() {
        if !titleTextView.text.isEmpty && !contentTextView.text.isEmpty {
            getDataToSave(title: titleTextView.text, content: contentTextView.text
                          , isLock: isLock
                          , idNote: self.idNote
                          , time: timeLabel.text ?? getCurrentDate())
        } else if titleTextView.text.isEmpty && !contentTextView.text.isEmpty {
            getDataToSave(title: "No title", content: contentTextView.text
                          , isLock: isLock
                          , idNote: self.idNote
                          , time: timeLabel.text ?? getCurrentDate())
        } else if !titleTextView.text.isEmpty && contentTextView.text.isEmpty {
            getDataToSave(title: titleTextView.text, content: "No content"
                          , isLock: isLock
                          , idNote: self.idNote
                          , time: timeLabel.text ?? getCurrentDate())
        } else if titleTextView.text.isEmpty && contentTextView.text.isEmpty && !self.idNote.isEmpty {
            deleteNote(idNote: idNote)
        }
    }
        
    func getDataToSave(title: String, content: String, isLock: Bool, idNote: String, time: String) {
        let context = getContext()
        
        if idNote != "" {
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
                Session.shared.reloadInList = true
                Session.shared.reloadInRoot = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
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
                Session.shared.reloadInList = true
                Session.shared.reloadInRoot = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateStatus(action: String) {
        let managedContext = getContext()
        
        let fetchNoteRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchNoteRequest.predicate = NSPredicate(format: "idNote = %@", self.idNote)

        do {
            let listNote = try managedContext.fetch(fetchNoteRequest)
            
            if !listNote.isEmpty {
                self.isPin = listNote.first?.value(forKey: "isPin") as? Bool ?? false
                self.isLock = listNote.first?.value(forKey: "isLock") as? Bool ?? false
                self.dataContent = parseToListNote(item: listNote.first!)
            } else {
                self.view.makeToast("You must save note before \(action)")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    @IBAction func openPhoto(_ sender: UIButton) {
        openLibararies()
    }
    
    @IBAction func stopCounting(_ sender: UIButton) {
        countdownView.isHidden = true
        if #available(iOS 14.0, *) {
            self.setupRightBarButton()
        } else {
            // Fallback on earlier versions
        }
    }
    
}

extension NoteContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.titleTextView.frame.size.height = self.titleTextView.contentSize.height
        Session.shared.reloadInList = true
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

extension NoteContentViewController: ManipulationDelegate {
    func pinNote() {
        if !idNote.isEmpty {
            self.pinNote(id: self.idNote, isPin: !self.isPin)
            Session.shared.reloadInList = true
        }
        updateStatus(action: "pin")
    }
    
    func lockNote() {
        if !idNote.isEmpty {
            if Session.shared.passwordNote.isEmpty {
                self.createPassword(actionAfterSetPassword: { [weak self] in
                    self?.lockNote(id: self?.idNote ?? "", isLock: true)
                    Session.shared.reloadInList = true
                    self?.updateStatus(action: "lock")
                    self?.navigationController?.popViewController(animated: true)
                })
            } else {
                self.lockNote(id: self.idNote, isLock: !self.isLock)
            }
            Session.shared.reloadInList = true
        }
        updateStatus(action: "lock")
        self.navigationController?.popViewController(animated: true)
    }
    
    func removeNote() {
        self.deleteNote(idNote: idNote)
        self.navigationController?.popViewController(animated: true)
    }
    
    func share() {
        let text = "Share note: \n\(dataContent?.titleNote ?? "") \n\(dataContent?.contentNote ?? "")"
        
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [.airDrop,
                                                        .postToFacebook,
                                                        .mail ,
                                                        .copyToPasteboard,
                                                        .message,
                                                        .postToTwitter]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func moveToFolder() {
        let alertController = UIAlertController(title: "Select folder", message: "Select folder want to move", preferredStyle: .actionSheet)
        let listFolder = self.getListFolder()
        
        let folder = UIAlertAction(title: "Quick Folder", style: .default) { [weak self] _ in
            self?.idFolder = ""
            self?.moveToFolder(idNote: self?.idNote ?? "" , idFolder: "")
        }
        
        alertController.addAction(folder)
        
        for item in listFolder {
            let folder = UIAlertAction(title: item.titleFolder, style: .default) { [weak self] _ in
                self?.idFolder = item.idFolder
                self?.moveToFolder(idNote: self?.idNote ?? "", idFolder: item.idFolder)
            }
            alertController.addAction(folder)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
}

extension NoteContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openLibararies() {
        let alert = UIAlertController(title: "Select Photo Type".localized, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo Library".localized, style: .default , handler:{ (UIAlertAction)in
            self.openMedia(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default , handler:{ (UIAlertAction)in
            self.openMedia(type: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    private func openMedia(type: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.sourceType = type
        vc.videoQuality = .typeHigh
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let attributedString = NSMutableAttributedString()
            let textAttachment = NSTextAttachment()
            textAttachment.image = image

            let oldWidth = textAttachment.image!.size.width;

            let scaleFactor = oldWidth / (self.contentTextView.frame.size.width - 10);
            guard let newImage = textAttachment.image?.cgImage else { return }
            textAttachment.image = UIImage(cgImage: newImage, scale: scaleFactor, orientation: .up)
            
            let attrStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.append(attrStringWithImage)
            contentTextView.attributedText = attributedString
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
