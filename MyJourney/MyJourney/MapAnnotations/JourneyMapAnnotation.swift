//
//  JourneyMapAnnotation.swift
//  MyJourney
//
//  Created by Jiawei Liao on 7/5/2024.
//

import MapKit

class JourneyMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var index: Int
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, index: Int, image: UIImage? = nil) {
        self.coordinate = coordinate
        // Index used to find the corresponding journey from list
        self.index = index
        self.image = image
    }
}

class JourneyMapAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            // Base image is "NoImageProvided"
            var annotationImage = UIImage(named: "NoImageProvided")
            
            // Try to find first image of journey
            if let journeyMapAnnotation = annotation as? JourneyMapAnnotation, let image = journeyMapAnnotation.image {
                annotationImage = image
            }
            
            // Resize image for map annotation
            let size = CGSize(width: 60, height: 60)
            UIGraphicsBeginImageContext(size)
            annotationImage!.draw(in: CGRect(x: 0, y: 0, width: 60, height: 60))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            image = resizedImage
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Journey Map Annotation View init coder error")
    }
    
    func configureView() {
        // Add border to annotation
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configureView()
    }
}
