//
//  ListNoteModel.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 21/11/2022.
//

import Foundation
import UIKit

enum ListNoteType {
    case title
    case search
    case item
}


struct ListNoteModel: DataCellArgument {
    var type : ListNoteType
    
    var title = ""
    var fontStyle = UIFont()
    
    var isLock = false
    var idNote = ""
    var titleNote = ""
    var contentNote = ""
    var date = ""
    
    init(type: ListNoteType) {
        self.type = type
    }
    
    init(type: ListNoteType, titleNote: String, contentNote: String, isLock: Bool, date: String, idNote: String) {
        self.type = type
        self.titleNote = titleNote
        self.contentNote = contentNote
        self.isLock = isLock
        self.date = date
        self.idNote = idNote
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getFont() -> UIFont {
        return fontStyle
    }
}
