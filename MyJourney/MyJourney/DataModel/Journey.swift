//
//  Journey.swift
//  MyJourney
//
//  Created by Jiawei Liao on 12/4/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class Journey: NSObject, Codable {
    @DocumentID var id: String?
    var date: Timestamp?
    var location: GeoPoint?
    var locationName: String?
    var journeyDescription: String?
    var images: [Data]?
    var weather: String?
}

enum CodingKeys: String, CodingKey {
    case id
    case date
    case location
    case journeyDescription
    case images
    case weather
}
