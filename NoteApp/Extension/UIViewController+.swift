//
//  UIViewController+.swift
//  MoneyManager
//
//  Created by Nam Nguyễn on 06/07/2022.
//

import UIKit
import CoreData

extension UIViewController {
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
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let label = UILabel(frame: CGRect(x: button.frame.maxX + 2, y: (button.frame.height - 20) / 2, width: 40, height: 20))
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.text = "Back"
            label.textAlignment = .center
            label.textColor = .black
            label.backgroundColor =  .clear
            button.addSubview(label)
            let barButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = barButton
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func touchBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
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
        return ListNoteModel(type: .item, titleNote: title, contentNote: content, isLock: isLock, date: date, idNote: idNote)
    }
}
