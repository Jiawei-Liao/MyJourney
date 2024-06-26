//
//  Login+CoreDataProperties.swift
//  MyJourney
//
//  Created by Jiawei Liao on 8/4/2024.
//


import Foundation
import CoreData


extension Login {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Login> {
        return NSFetchRequest<Login>(entityName: "Login")
    }

    @NSManaged public var email: String?

}

extension Login : Identifiable {

}
