//
//  NoteContentViewController.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit

class NoteContentViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButton()
        self.navigationController?.isNavigationBarHidden = false
    }
}
