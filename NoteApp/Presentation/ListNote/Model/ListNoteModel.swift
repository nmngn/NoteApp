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
    
    var titleDescription = ""
    var description = ""
    var date = ""
    
    init(type: ListNoteType) {
        self.type = type
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getFont() -> UIFont {
        return fontStyle
    }
}
