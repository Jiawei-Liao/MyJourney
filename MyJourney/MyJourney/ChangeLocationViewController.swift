//
//  ChangeLocationViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 12/4/2024.
//

import UIKit
import MapKit
import FirebaseFirestore

protocol ChangeLocationDelegate: AnyObject {
    func changedToLocation(latitude: Double, longitude: Double, locationName: String)
}

class ChangeLocationViewController: UIViewController, UITextFieldDelegate, GeocodingProtocol {
    
    // Dismissing keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // View controller variables
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // Change location button action
    @IBAction func changeLocation(_ sender: Any) {
        if let lat = coordinates?.latitude, let long = coordinates?.longitude, let locationName = locationNameTextField.text {
            delegate?.changedToLocation(latitude: lat, longitude: long, locationName: locationName)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // Long press gesture listener
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended{
            let tappedLocation = sender.location(in: mapView)
            coordinates = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            newTappedLocation()
        }
    }
    
    // Re-add annotations
    func newTappedLocation() {
        // Remove previous annotation
        if let annotation = annotation {
            mapView.removeAnnotation(annotation)
        }
        
        Task {
            if let coordinates = coordinates{
                // Get location name from API
                let locationName = await getAddress(lat: coordinates.latitude, lon: coordinates.longitude) ?? ""
                locationNameTextField.text = locationName
                
                // Create annotation and focus on it
                annotation = TappedLocationAnnotation(coordinate: coordinates, title: locationName)
                if let annotation = annotation {
                    mapView.addAnnotation(annotation)
                    focusOn(annotation: annotation)
                }
            }
        }
    }
    
    // Focus map onto annotated location
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // Variables
    var delegate: ChangeLocationDelegate?
    var locationName: String?
    var coordinates: CLLocationCoordinate2D?
    var annotation: TappedLocationAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationNameTextField.text = locationName ?? ""
        locationNameTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        newTappedLocation()
    }
}
