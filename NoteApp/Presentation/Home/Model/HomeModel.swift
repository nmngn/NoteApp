//
//  HomeModel.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 15/11/2022.
//

import Foundation
import UIKit

protocol DataCellArgument {
    func getTitle() -> String
    func getFont() -> UIFont
}

enum HomeType {
    case title
    case search
    case folder
}

struct HomeModel: DataCellArgument {
    var type : HomeType
    
    var title = ""
    var fontStyle = UIFont()
    
    var titleFolder = ""
    var imageFolder = ""
    var countNote = 0
    
    init(type: HomeType) {
        self.type = type
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getFont() -> UIFont {
        return fontStyle
    }
}
