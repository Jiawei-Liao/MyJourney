//
//  FirebaseController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 12/4/2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, FirebaseProtocol {
    // Variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var journeyList: [Journey]
    var journeyListListener: ListenerRegistration?
    
    var authController: Auth
    var database: Firestore
    var journeyRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    // Setup variables
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        journeyList = [Journey]()
        
        super.init()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .journey {
            listener.onJourneyChange(change: .update, journey: journeyList)
        }
    }
    
    func removeListener(listener: any DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addJourney(descriptionText: String, journeyDate: Date, journeyLocationName: String, journeyCoordinates: GeoPoint, weather: String, imageDataList: [Data]) {
        // Create journey object
        let journey = Journey()
        journey.date = Timestamp(date: journeyDate)
        journey.location = journeyCoordinates
        journey.locationName = journeyLocationName
        journey.journeyDescription = descriptionText
        journey.images = imageDataList
        journey.weather = weather
        
        // Add to firebase
        do {
            if let journeyRef = try journeyRef?.addDocument(from: journey) {
                journey.id = journeyRef.documentID
            }
        } catch {
            print("Failed to serialise journey")
        }
    }
    
    func deleteJourney(journey: Journey) {
        if let journeyID = journey.id {
            journeyRef?.document(journeyID).delete()
        }
    }
    
    func cleanup() {
    }
    
    func getJourneyByID(_ id: String) -> Journey? {
        // Loop through journey list to find a journey with matching id
        for journey in journeyList {
            if journey.id == id {
                return journey
            }
        }
        // No journey was found, return nil
        return nil
    }
    
    func setupJourneyListener() {
        // Reset journey list and listener
        journeyListListener?.remove()
        journeyList = [Journey]()
        
        // Add listener to the journey reference in firebase
        journeyListListener = journeyRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch document with error: \(String(describing: error))")
                return
            }
            self.parseJourneySnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseJourneySnapshot(snapshot: QuerySnapshot) {
        // Make changes to journey list
        snapshot.documentChanges.forEach { (change) in
            var journey: Journey
            
            do {
                journey = try change.document.data(as: Journey.self)
            } catch {
                fatalError("Unable to decode journey: \(error.localizedDescription)")
            }
            
            if change.type == .added {
                journeyList.insert(journey, at: Int(change.newIndex))
            } else if change.type == .modified {
                journeyList.remove(at: Int(change.oldIndex))
                journeyList.insert(journey, at: Int(change.newIndex))
            } else if change.type == .removed {
                journeyList.remove(at: Int(change.oldIndex))
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.journey {
                    listener.onJourneyChange(change: .update, journey: journeyList)
                }
            }
        }
    }
    
    func login(email: String, password: String) async -> String {
        do {
            // Authenticate via firebase
            let authDataResult = try await authController.signIn(withEmail: email, password: password)
            currentUser = authDataResult.user
            guard let currentUser = currentUser else {
                return "Failed to initialize user"
            }
            // Setup user references and listeners
            journeyRef = database.collection("users").document(currentUser.uid).collection("journeys")
            self.setupJourneyListener()
            return ""
        } catch {
            print("Firebase Authentication Failed with Error: \(String(describing: error))")
            return error.localizedDescription
        }
    }
    
    func signup(email: String, password: String) async -> String {
        do {
            // Authenticate via firebase
            let authDataResult = try await authController.createUser(withEmail: email, password: password)
            currentUser = authDataResult.user
            guard let currentUser = currentUser else {
                return "Failed to initialize user"
            }
            // Setup user references and listeners
            journeyRef = database.collection("users").document(currentUser.uid).collection("journeys")
            self.setupJourneyListener()
            return ""
        } catch {
            print("Firebase Authentication Failed with Error: \(String(describing: error))")
            return error.localizedDescription
        }
    }
}
