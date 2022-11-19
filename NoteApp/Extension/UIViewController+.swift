//
//  UIViewController+.swift
//  MoneyManager
//
//  Created by Nam Nguyễn on 06/07/2022.
//

import UIKit

extension UIViewController {
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
        let backItem = UIBarButtonItem(image:  UIImage(named: "ic_left_arrow")
                                       , style: .plain, target: self, action: #selector(touchBackButton))
        navigationItem.leftBarButtonItems = [backItem]
    }
    
    @objc func touchBackButton() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    

}
