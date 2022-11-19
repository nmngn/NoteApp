//
//  TitleTableViewCell.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 16/11/2022.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupData(data: HomeModel) {
        titleLabel.text = data.title
        titleLabel.font = data.fontStyle
    }
}
