//
//  TappedLocation.swift
//  MyJourney
//
//  Created by Jiawei Liao on 2/5/2024.
//

import MapKit

class TappedLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }
}
