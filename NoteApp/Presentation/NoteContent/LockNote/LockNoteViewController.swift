//
//  LockNoteViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 25/11/2022.
//

import UIKit

class LockNoteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
    }

    @IBAction func unlockAction(_ sender: UIButton) {
        var textField = UITextField()
        let alertController = UIAlertController(title: "View Note", message: "To view locked note, enter the note password", preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            if let text = textField.text, !text.isEmpty {
                print(text)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Password"
            textField = alertTextField
        }
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
