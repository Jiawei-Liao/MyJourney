//
//  CoreDataController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 8/4/2024.
//

import Foundation
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    // Variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    // Initialise variables
    override init() {
        persistentContainer = NSPersistentContainer(name: "MyJourney-DataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        
        super.init()
    }
    
    func cleanup() {
        // Save view context on cleanup
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func getLogin() -> Login? {
        // Get login from storage
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        
        do {
            if let login = try context.fetch(fetchRequest).last {
                return login
            }
        } catch {
            fatalError("Failed to get login information with error: \(error)")
        }
        return nil
    }
    
    func setLogin(email: String) {
        // Set login in storage
        let context = persistentContainer.viewContext
        
        // Try to update previous instance of login, if it exists
        let fetchRequest: NSFetchRequest<Login> = Login.fetchRequest()
        
        do {
            if let existingLogin = try context.fetch(fetchRequest).last {
                existingLogin.email = email
            } else {
                let login = Login(context: context)
                login.email = email
            }
            
            try context.save()
        } catch {
            fatalError("Failed to save login information with error: \(error)")
        }
    }
    
    func getTutorialDone() -> Tutorial? {
        // Get tutorial done from storage
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tutorial> = Tutorial.fetchRequest()
        
        do {
            if let tutorial = try context.fetch(fetchRequest).last {
                return tutorial
            }
        } catch {
            fatalError("Failed to get tutorial information with error: \(error)")
        }
        return nil
    }
    
    func setTutorialDone(status: Bool) {
        // Set login in storage
        let context = persistentContainer.viewContext
        
        // Try to update previous instance of tutorial, if it exists
        let fetchRequest: NSFetchRequest<Tutorial> = Tutorial.fetchRequest()
        
        do {
            if let existingTutorial = try context.fetch(fetchRequest).last {
                existingTutorial.tutorialDone = status
            } else {
                let tutorial = Tutorial(context: context)
                tutorial.tutorialDone = status
            }
            
            try context.save()
        } catch {
            fatalError("Failed to save tutorial information with error: \(error)")
        }
    }
    
    func getCurrentJourney() -> [CurrentJourney] {
        // Get journey from storage
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CurrentJourney> = CurrentJourney.fetchRequest()
        
        do {
            let currentJourney = try context.fetch(fetchRequest)
            return currentJourney
        } catch {
            fatalError("Failed to get current journey information with error: \(error)")
        }
    }
    
    func setCurrentJourney(descriptionText: String, journeyDate: Date, journeyLocationName: String, latitude: Int64, longitude: Int64, weather: String) {
        // Create new journey and save to storage
        let context = persistentContainer.viewContext
        
        let currentJourney = CurrentJourney(context: context)
        currentJourney.descriptionText = descriptionText
        currentJourney.journeyDate = journeyDate
        currentJourney.journeyLocationName = journeyLocationName
        currentJourney.latitude = latitude
        currentJourney.longitude = longitude
        currentJourney.weather = weather
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save current journey information with error: \(error)")
        }
    }
    
    func removeCurrentJourney() {
        // Remove journey from storag
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CurrentJourney> = CurrentJourney.fetchRequest()
        
        do {
            let currentJourney = try context.fetch(fetchRequest)
            
            for journey in currentJourney {
                context.delete(journey)
            }
            
            try context.save()
        } catch {
            fatalError("Failed to remove current journey information with error: \(error)")
        }
    }
    
    func addListener(listener: any DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
