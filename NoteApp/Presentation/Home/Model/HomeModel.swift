//
//  HomeModel.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 15/11/2022.
//

import Foundation
import UIKit

enum HomeType {
    case title
    case search
    case folder
}

struct HomeModel {
    var type : HomeType
    
    var title = ""
    var fontStyle = UIFont()
    
    var titleFolder = ""
    var imageFolder = ""
    var countNote = 0
    
    init(type: HomeType) {
        self.type = type
    }
}
