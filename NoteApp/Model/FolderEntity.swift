//
//  FolderEntity.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 14/11/2022.
//

import Foundation
import CoreData

extension FolderEntity {
    func toEntity(in context: NSManagedObjectContext) -> FolderEntity {
        let entity: FolderEntity = FolderEntity(context: context)
        entity.idFolder = idFolder
        entity.title = title
        return entity
    }
}
