//
//  SettingNoteViewController.swift
//  NoteApp
//
//  Created by Nam Ngây on 30/11/2022.
//

import UIKit
import CoreData

protocol ManipulationDelegate {
    func pinNote()
    func lockNote()
    func removeNote()
}

class SettingNoteViewController: UIViewController {
    @IBOutlet weak var titleNote: UILabel!
    @IBOutlet weak var dateNote: UILabel!
    @IBOutlet weak var pinText: UILabel!
    @IBOutlet weak var lockText: UILabel!
    
    @IBOutlet weak var imagePin: UIImageView!
    @IBOutlet weak var imageLock: UIImageView!
    
    var model: ListNoteModel?
    var delegate: ManipulationDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    func setupData() {
        if let model = model {
            titleNote.text = model.titleNote
            dateNote.text = model.date
            pinText.text = model.isPin ? "Unpin" : "Pin"
            lockText.text = model.isLock ? "Unlock" : "Lock"
            imagePin.image = model.isPin ? UIImage(named: "ic_unpin") : UIImage(named: "ic_pin")
            imageLock.image = model.isPin ? UIImage(named: "ic_unlock") : UIImage(named: "ic_lock2")
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pinAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.pinNote()
    }
    
    @IBAction func lockAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.lockNote()
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.removeNote()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
    }
    
}
