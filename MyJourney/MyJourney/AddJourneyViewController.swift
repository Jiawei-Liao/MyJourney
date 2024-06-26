//
//  AddJourneyViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 6/4/2024.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseFirestore

class AddJourneyViewController: UIViewController, CLLocationManagerDelegate, ChangeDateDelegate, ChangeLocationDelegate, AddImageDataDelegate, GeocodingProtocol, WeatherProtocol, GetWeatherImageDelegate {
    // Location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            Task {
                // Update locationName and coordinates with last updated location
                let locationName = await getAddress(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                changedToLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, locationName: locationName ?? "")
                findWeather()
            }
        }
        // Stop updating locations as it is not needed anymore
        locationManager.stopUpdatingLocation()
    }
    
    // Delegate functions
    func changedToLocation(latitude: Double, longitude: Double, locationName: String) {
        // Updates the variables and button text based on change
        journeyCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        journeyLocationName = locationName
        locationLabel.text = journeyLocationName
        findWeather()
    }
    
    func addImageData(_ data: [Data]) {
        // Updates image data list based on change
        imageDataList = data
        imageLabel.text = "\(data.count) Images selected"
    }
    
    func changedToDate(_ date: Date) {
        // Updates the variables and button text based on change
        let formattedTime = dateFormatter.string(from: date)
        dateButton.setTitle(formattedTime, for: .normal)
        journeyDate = date
        findWeather()
    }
    
    // Not a delegate function but it serves a similar purpose, to update weather data when date or location is changed
    func findWeather() {
        Task {
            let weath = "Unable to find weather information"
            if let coordinate = journeyCoordinates {
                if let weath = await getWeather(lat: coordinate.latitude, lon: coordinate.longitude, date: journeyDate) {
                    weatherLabel.text = weath
                    weatherImage.image = getWeatherImage(for: weath)
                }
            } else {
                weatherLabel.text = weath
                weatherImage.image = getWeatherImage(for: weath)
            }
        }
    }
    
    // Go to other view controllers
    @IBAction func changeDate(_ sender: Any) {
        performSegue(withIdentifier: "changeDateSegue", sender: sender)
    }
    @IBOutlet weak var dateButton: UIButton!
    
    @IBAction func changeLocation(_ sender: Any) {
        performSegue(withIdentifier: "changeLocationSegue", sender: sender)
    }
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBAction func viewImages(_ sender: Any) {
        performSegue(withIdentifier: "viewImagesSegue", sender: sender)
    }
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    // Add journey
    @IBAction func addJourney(_ sender: Any) {
        // Checking for user input before pushing to firebase
        guard let descriptionText = descriptionTextField.text else {
            displayMessage(title: "No description", message: "Please provide a description for your journey!")
            return
        }
        guard let locationName = journeyLocationName, let journeyCoordinates = journeyCoordinates else {
            displayMessage(title: "No location", message: "Please provide a valid location for your journey!")
            return
        }
        guard let weath = weatherLabel.text else {
            displayMessage(title: "No Weather", message: "Weather data not available. Please try again later")
            return
        }
        
        // Push journey to firebase
        firebaseController?.addJourney(descriptionText: descriptionText, journeyDate: journeyDate, journeyLocationName: locationName, journeyCoordinates: journeyCoordinates.toGeoPoint(), weather: weath, imageDataList: imageDataList)
        
        // Remove core data
        databaseController?.removeCurrentJourney()
        
        // Set boolean to true to indicate pushing to firebase, so don't save to core data
        addingJourney = true
        navigationController?.popViewController(animated: true)
    }
    
    // Date variables
    var journeyDate = Date()
    var dateFormatter = DateFormatter()
    
    // Location variables
    var journeyCoordinates: CLLocationCoordinate2D?
    var journeyLocationName: String?
    var locationManager: CLLocationManager = CLLocationManager()
    
    // Description variable
    @IBOutlet weak var descriptionTextField: UITextView!
    
    // Image variable
    var imageDataList = [Data]()
    
    weak var databaseController: DatabaseProtocol?
    weak var firebaseController: FirebaseProtocol?
    
    var addingJourney = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup keyboard
        descriptionTextField.becomeFirstResponder()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        firebaseController = appDelegate?.firebaseController
        
        // Setup date formatter
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Setup location manager
        locationManager.delegate = self
        
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Load data from CoreData if available
        let currentJourneys = databaseController?.getCurrentJourney()
        if currentJourneys!.count == 0 {
            // If not available, initialise variables
            let currentTime = Date()
            journeyDate = currentTime
            let formattedTime = dateFormatter.string(from: currentTime)
            dateButton.setTitle(formattedTime, for: .normal)
            
            locationManager.startUpdatingLocation()
            
            findWeather()
        } else {
            // If available, get the journey
            guard let currentJourney = currentJourneys?.last else {
                return
            }
            
            journeyDate = currentJourney.journeyDate!
            let formattedTime = dateFormatter.string(from: journeyDate)
            dateButton.setTitle(formattedTime, for: .normal)
            
            journeyCoordinates = CLLocationCoordinate2D(latitude: Double(currentJourney.latitude), longitude: Double(currentJourney.longitude))

            journeyLocationName = currentJourney.journeyLocationName
            locationLabel.text = journeyLocationName
            
            weatherLabel.text = currentJourney.weather
            weatherImage.image = getWeatherImage(for: currentJourney.weather ?? "")
            
            descriptionTextField.text = currentJourney.descriptionText
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Don't save to core data if adding journey
        if !addingJourney {
            guard let desc = descriptionTextField.text, let journeyName = journeyLocationName, let lat = journeyCoordinates?.latitude, let lon = journeyCoordinates?.longitude, let weath = weatherLabel.text else {
                print("Failed to get data")
                return
            }
            databaseController?.setCurrentJourney(descriptionText: desc, journeyDate: journeyDate, journeyLocationName: journeyName, latitude: Int64(lat), longitude: Int64(lon), weather: weath)
        }
        
        super.viewDidDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeDateSegue" {
            let destination = segue.destination as! ChangeDateViewController
            destination.delegate = self
            destination.initialDate = journeyDate
        } else if segue.identifier == "changeLocationSegue" {
            let destination = segue.destination as! ChangeLocationViewController
            destination.delegate = self
            destination.locationName = journeyLocationName
            destination.coordinates = journeyCoordinates
        } else if segue.identifier == "viewImagesSegue" {
            let destination = segue.destination as! ViewImagesCollectionViewController
            destination.delegate = self
            destination.imageDataList = imageDataList
        }
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
