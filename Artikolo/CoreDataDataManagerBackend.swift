//
//  CoreDataDataManagerBackend.swift
//  Artikolo
//
//  Created by Grant Butler on 4/30/17.
//  Copyright © 2017 Grant Butler. All rights reserved.
//

import Foundation
import CoreData

class CoreDataDataManagerBackend: DataManagerBackend {
    
    private let container: NSPersistentContainer
    var urls: [URL] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Article")
        
        do {
            let articleObjects = try container.viewContext.fetch(fetchRequest)
            return articleObjects.map { $0.value(forKey: "url") as! URL }
        }
        catch {
            return []
        }
    }
    
    private static func makePersistentContainer(name: String) -> NSPersistentContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Artikolo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    init(containerName: String) {
        container = type(of: self).makePersistentContainer(name: containerName)
    }
    
    func save(url: URL) {
        let context = container.newBackgroundContext()
        context.performAndWait {
            let articleObject = NSEntityDescription.insertNewObject(forEntityName: "Article", into: context)
            articleObject.setValue(url, forKey: "url")
            
            do {
                try context.save()
            }
            catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func reset() throws {
        let coordinator = container.persistentStoreCoordinator
        let stores = coordinator.persistentStores
        try stores.forEach({ (store) in
            guard let storeURL = store.url else { return }
            try coordinator.destroyPersistentStore(at: storeURL, ofType: store.type, options: store.options)
            try coordinator.addPersistentStore(ofType: store.type, configurationName: store.configurationName, at: store.url, options: store.options)
        })
        
    }
    
}
