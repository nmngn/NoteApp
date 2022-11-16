//
//  HomeModel.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 15/11/2022.
//

import Foundation

enum HomeType {
    case title
    case search
    case folder
}

struct HomeModel {
    var type : HomeType
    var title = ""
    var countNote = 0
    
    init(type: HomeType) {
        self.type = type
    }
}
