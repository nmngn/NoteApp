//
//  UIViewController+.swift
//  MoneyManager
//
//  Created by Nam Nguyễn on 06/07/2022.
//

import UIKit
import CoreData

extension UIViewController {
    
    // MARK: - Context
    func getContext() -> NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)}
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }
    
    class func instantiateViewControllerFromStoryboard(storyboardName: String) -> Self {
        return instantiateFromStoryboardHelper(storyboardName: storyboardName, storyboardId: self.className)
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboardName: String, storyboardId: String) -> T {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    func openAlert(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getCurrentDate() -> String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        return dateString
    }
    
    func setupNavigationButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        if #available(iOS 13.0, *) {
            let button =  UIButton(type: .custom)
            button.setImage(UIImage(named: "ic_left_arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(touchBackButton), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            button.setTitle("Back", for: .normal)
            button.setTitleColor(.black, for: .normal)
            let barButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = barButton
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func touchBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - CoreData
    func parseToHomeModel(item: NSManagedObject) -> HomeModel {
        let id = item.value(forKey: "idFolder") as? String ?? ""
        let text = item.value(forKey: "title") as? String ?? ""
        let data = HomeModel(type: .folder, titleFolder: text, id: id)
        return data
    }
    
    func parseToListNote(item: NSManagedObject) -> ListNoteModel {
        let isLock = item.value(forKey: "isLock") as? Bool ?? false
        let title = item.value(forKey: "title") as? String ?? ""
        let content = item.value(forKey: "detail") as? String ?? ""
        let date = item.value(forKey: "dateTime") as? String ?? ""
        let idNote = item.value(forKey: "idNote") as? String ?? ""
        let isPin = item.value(forKey: "isPin") as? Bool ?? false
        let idFolder = item.value(forKey: "idFolder") as? String ?? ""
        return ListNoteModel(type: .item, titleNote: title, contentNote: content, isLock: isLock, date: date, idNote: idNote, isPin: isPin, idFolder: idFolder)
    }
    
    func presentAlertUnlock(actionAfterUnlockSuccess: @escaping () -> Void) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "View Note", message: "To view locked note, enter the note password", preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            if let text = textField.text, !text.isEmpty {
                if let result = self?.checkPassword(text: text) {
                    if result {
                        actionAfterUnlockSuccess()
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                        self?.view.makeToast("Password wrong!")
                    }
                } else {
                    self?.dismiss(animated: true, completion: nil)
                    self?.view.makeToast("Password wrong!")
                }
                print(text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Password"
            alertTextField.isSecureTextEntry = true
            textField = alertTextField
        }
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func createPassword(actionAfterSetPassword: @escaping () -> Void) {
        var newPassword = UITextField()
        var confirmPassword = UITextField()
        
        let alert = UIAlertController(title: "Notify", message: "You have not set password before, let create your password", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            newPassword = textField
            textField.placeholder = "New password"
        }
        
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            confirmPassword = textField
            textField.placeholder = "Confirm password"
        }
        
        let saveAction = UIAlertAction(title: "Ok", style: .default) { [weak self] action in
            if let newText = newPassword.text, let newConfirm = confirmPassword.text {
                if !newText.isEmpty && !newConfirm.isEmpty {
                    if newText == newConfirm {
                        self?.createPassword(text: newConfirm)
                        actionAfterSetPassword()
                    } else {
                        self?.view.makeToast("Password do not match")
                    }
                } else {
                    self?.view.makeToast("Password must not empty")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func createPassword(text: String) {
        let key32 = (UIDevice.current.identifierForVendor?.uuidString.prefix(32))!
        let iv = (UIDevice.current.identifierForVendor?.uuidString.suffix(16))!
        let aes256 = AES(key: String(key32), iv: String(iv))
        let encryptPassword = aes256?.encrypt(string: text)
//        let result = aes256?.decrypt(data: encryptPassword)
        Session.shared.passwordNote = encryptPassword ?? Data()
        UserDefaults.standard.setValue(encryptPassword, forKey: "password")
    }
    
    func checkPassword(text: String) -> Bool {
        let key32 = (UIDevice.current.identifierForVendor?.uuidString.prefix(32))!
        let iv = (UIDevice.current.identifierForVendor?.uuidString.suffix(16))!
        let aes256 = AES(key: String(key32), iv: String(iv))

        if let encryptPassword = UserDefaults.standard.value(forKey: "password") as? Data {
            if let result = aes256?.decrypt(data: encryptPassword) {
                if !text.isEmpty && !result.isEmpty {
                    if result == text {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return false
    }
    
    func lockNote(id: String, isLock: Bool) {
        let context = self.getContext()
        let fetchRequest : NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idNote == %@", id)
        do {
            let results = try context.fetch(fetchRequest)
            if let note = results.first {
                note.isLock = isLock
            }
            try context.save()
            self.view.makeToast(isLock ? "Lock" : "Unlock")
            Session.shared.reloadInList = true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func pinNote(id: String, isPin: Bool) {
        let context = self.getContext()
        let fetchRequest : NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idNote == %@", id)
        do {
            let results = try context.fetch(fetchRequest)
            if let note = results.first {
                note.isPin = isPin
            }
            try context.save()
            self.view.makeToast(isPin ? "Pin" : "Unpin")
            Session.shared.reloadInList = true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteNote(idNote: String) {
        let context = getContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        request.predicate = NSPredicate(format: "idNote = %@", idNote)

        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            Session.shared.reloadInRoot = true
            Session.shared.reloadInList = true
            self.view.makeToast("Deleted")
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func getListFolder() -> [HomeModel] {
        let managedContext = getContext()
        var listFolder = [HomeModel]()
        
        let fetchFolderRequest = NSFetchRequest<NSManagedObject>(entityName: "FolderEntity")
        
        do {
            let data = try managedContext.fetch(fetchFolderRequest)
            
            for item in data {
                let folder = parseToHomeModel(item: item)
                listFolder.append(folder)
            }
            return listFolder
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return listFolder
    }
}
