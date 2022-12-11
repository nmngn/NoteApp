//
//  ItemTableViewCell.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var isLock: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupData(model: ListNoteModel) {
        titleLabel.text = model.titleNote
        contentLabel.text = "\(model.date.prefix(10))   \(model.contentNote)"
        if model.isLock {
            isLock.image = UIImage(named: "ic_lock")
        } else {
            isLock.image = UIImage()
        }
    }
}
