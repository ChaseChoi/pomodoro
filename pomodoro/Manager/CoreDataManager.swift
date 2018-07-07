//
//  CoreDataManager.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/21.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import CoreData

class CoreDataManager {
    // MARK: - Properties
    private let modelName: String
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    // MARK: - NSPersistentContainer
    private lazy var storeContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Initialization
    init(modelName: String) {
        self.modelName = modelName
        setupNotificationHandling()
    }
    
    // MARK: -
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification) {
        saveChanges()
    }
    private func saveChanges() {
        guard managedObjectContext.hasChanges else {
            return
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Managed Object Context")
            print("\(error), \(error.localizedDescription)")
        }
        
    }
    
}
