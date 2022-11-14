//
//  CoreDataManager.swift
//  NoteApp
//
//  Created by Nam Nguyễn on 14/11/2022.
//

import CoreData

protocol FolderManager {
    func saveFolder(folder: FolderEntity)
    func getListFolderList()
}

protocol NoteManager {
    func saveNote(note: NoteEntity)
    func getListNote()
}

class CoreDataManager: FolderManager, NoteManager {
    
    private lazy var folderPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FolderEntity")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var notePersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteEntity")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveFolder(folder: FolderEntity) {
        self.folderPersistentContainer.performBackgroundTask { context in
            do {
                _ = folder.toEntity(in: context)
                try context.save()
            } catch {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func getListFolderList() {
        var folder = [FolderEntity]()
        
    }
    
    func saveNote(note: NoteEntity) {
        <#code#>
    }
    
    func getListNote() {
        <#code#>
    }
}
