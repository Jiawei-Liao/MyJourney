//
//  InnterJourneyTableViewCell.swift
//  MyJourney
//
//  Created by Jiawei Liao on 16/5/2024.
//

import Foundation
import UIKit

class IndividualJourneyTableViewCell: UITableViewCell {
    // Cell variables
    @IBOutlet weak var nextViewVerticalLine: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var journeyImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var journey: Journey? = nil {
        didSet {
            // Set cell variables based on given journey
            if let journey = journey {
                if let image = journey.images?.first {
                    journeyImageView.image = UIImage(data: image)
                } else {
                    journeyImageView.image = UIImage(named: "NoImageProvided")
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current
                dateFormatter.timeStyle = .short

                if let date = journey.date?.dateValue() {
                    let time = dateFormatter.string(from: date)
                    timeLabel.text = time
                } else {
                    timeLabel.text = ""
                }
                
                locationLabel.text = journey.locationName
                weatherLabel.text = journey.weather
                descriptionLabel.text = journey.journeyDescription
            }
        }
    }
}
