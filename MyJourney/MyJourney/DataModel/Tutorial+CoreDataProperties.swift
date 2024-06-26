//
//  Tutorial+CoreDataProperties.swift
//  MyJourney
//
//  Created by Spencer McNamara on 2/6/2024.
//
//

import Foundation
import CoreData


extension Tutorial {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tutorial> {
        return NSFetchRequest<Tutorial>(entityName: "Tutorial")
    }

    @NSManaged public var tutorialDone: Bool

}

extension Tutorial : Identifiable {

}
