//
//  Session.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 25/11/2022.
//

import Foundation

class Session {
    static let shared = Session()
    
    var reloadInList = false
    var reloadInRoot = false
}
