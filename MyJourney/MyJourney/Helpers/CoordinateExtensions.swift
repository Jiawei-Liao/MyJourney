//
//  CoordinateExtensions.swift
//  MyJourney
//
//  Created by Jiawei Liao on 3/5/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore

// Extensions to make converting from Swift coordinates to Firebase coordinates easier

extension CLLocationCoordinate2D {
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

extension GeoPoint {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
