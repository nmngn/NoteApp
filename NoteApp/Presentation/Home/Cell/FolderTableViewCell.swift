//
//  FolderTableViewCell.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 16/11/2022.
//

import UIKit

class FolderTableViewCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleFolder: UILabel!
    @IBOutlet weak var imageFolder: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupData(data: HomeModel) {
        imageFolder.image = UIImage(named: data.imageFolder)
        titleFolder.text = data.titleFolder
        countLabel.text = "\(data.countNote)"
    }
}
