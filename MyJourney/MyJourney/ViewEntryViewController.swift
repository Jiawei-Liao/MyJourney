//
//  ViewEntryViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 28/4/2024.
//

import UIKit

class ViewEntryViewController: UIViewController, GetWeatherImageDelegate {
    
    // View controller variables
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBAction func viewImages(_ sender: Any) {
        performSegue(withIdentifier: "viewEntryImagesSegue", sender: sender)
    }
    
    // Variables
    var journey: Journey?
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise date formatter
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Set view controller text
        if let journey = journey {
            if let date = journey.date?.dateValue() {
                dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
            }
            descriptionTextField.text = journey.journeyDescription ?? ""
            locationLabel.text = journey.locationName
            weatherLabel.text = journey.weather
            weatherImage.image = getWeatherImage(for: journey.weather!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEntryImagesSegue" {
            let destination = segue.destination as! ViewEntryImagesCollectionViewController
            destination.imageDataList = journey?.images ?? [Data]()
        }
    }
}
