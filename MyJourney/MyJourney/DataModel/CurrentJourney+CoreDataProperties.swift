//
//  CurrentJourney+CoreDataProperties.swift
//  MyJourney
//
//  Created by Jiawei Liao on 25/4/2024.
//
//

import Foundation
import CoreData


extension CurrentJourney {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentJourney> {
        return NSFetchRequest<CurrentJourney>(entityName: "CurrentJourney")
    }

    @NSManaged public var descriptionText: String?
    @NSManaged public var journeyDate: Date?
    @NSManaged public var journeyLocationName: String?
    @NSManaged public var latitude: Int64
    @NSManaged public var longitude: Int64
    @NSManaged public var weather: String?
    
}

extension CurrentJourney : Identifiable {

}
