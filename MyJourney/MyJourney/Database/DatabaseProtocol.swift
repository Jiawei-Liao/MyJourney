//
//  DatabaseProtocol.swift
//  MyJourney
//
//  Created by Jiawei Liao on 8/4/2024.
//

import Foundation
import FirebaseFirestore

// Database change types
enum DatabaseChange {
    case add
    case remove
    case update
}

// Database listener types
enum ListenerType {
    case login
    case journey
}

// Database listener protocol
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onJourneyChange(change: DatabaseChange, journey: [Journey])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func getLogin() -> Login?
    func setLogin(email: String)
    
    func getTutorialDone() -> Tutorial?
    func setTutorialDone(status: Bool)
    
    func getCurrentJourney() -> [CurrentJourney]
    func setCurrentJourney(descriptionText: String, journeyDate: Date, journeyLocationName: String, latitude: Int64, longitude: Int64, weather: String)
    func removeCurrentJourney()
}

// Firebase listener protocol
protocol FirebaseProtocol: AnyObject {
    var journeyList: [Journey] { get }
    
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addJourney(descriptionText: String, journeyDate: Date, journeyLocationName: String, journeyCoordinates: GeoPoint, weather: String, imageDataList: [Data])
    func deleteJourney(journey: Journey)
    
    func login(email: String, password: String) async -> String
    func signup(email: String, password: String) async -> String
}
