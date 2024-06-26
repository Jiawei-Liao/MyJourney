//
//  MapViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 6/4/2024.
//

import UIKit
import MapKit
import FirebaseFirestore

class MapViewController: UIViewController, MKMapViewDelegate, DatabaseListener {
    @IBAction func logout(_ sender: Any) {
        // Get login view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        // Transition to that view controller
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }
    
    func onJourneyChange(change: DatabaseChange, journey: [Journey]) {
        journeyList = journey
        journeyList.sort{ (journey1, journey2) -> Bool in
            return journey1.date!.compare(journey2.date!) == .orderedDescending
        }
        
        // Remove annotations
        mapView.removeAnnotations(annotationList)
        annotationList = [JourneyMapAnnotation]()
        
        for (index, journey) in journeyList.enumerated() {
            if let location = journey.location?.toCLLocationCoordinate2D() {
                if let imageData = journey.images?.first {
                    let annotation = JourneyMapAnnotation(coordinate: location, index: index, image: UIImage(data: imageData))
                    annotationList.append(annotation)
                } else {
                    let annotation = JourneyMapAnnotation(coordinate: location, index: index)
                    annotationList.append(annotation)
                }
            }
        }
        
        mapView.addAnnotations(annotationList)
        
        if let firstAnnotation = annotationList.first {
            focusOn(annotation: firstAnnotation)
        }
    }
    
    // Focus map onto annotated location
    func focusOn(annotation: MKAnnotation) {
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // View controller variables
    @IBOutlet weak var mapView: MKMapView!
    
    // Variables
    weak var firebaseController: FirebaseProtocol?
    var journeyList = [Journey]()
    var annotationList = [JourneyMapAnnotation]()
    var listenerType: ListenerType = .journey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firebaseController?.removeListener(listener: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEntrySegue" {
            let destination = segue.destination as! ViewEntryViewController
            let selectedJourney = sender as! Journey
            destination.journey = selectedJourney
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard let journeyMapAnnotation = annotation as? JourneyMapAnnotation else {
            return nil
        }
        
        let reuseIdentifier = "JourneyMapAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = JourneyMapAnnotationView(annotation: journeyMapAnnotation, reuseIdentifier: reuseIdentifier)
        } else {
            annotationView?.annotation = journeyMapAnnotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? JourneyMapAnnotation {
            let index = annotation.index
            let selectedJourney = journeyList[index]
            performSegue(withIdentifier: "viewEntrySegue", sender: selectedJourney)
        }
    }
}
