//
//  GetWeatherImage.swift
//  MyJourney
//
//  Created by Jiawei Liao on 21/5/2024.
//

import Foundation
import UIKit

protocol GetWeatherImageDelegate {
    func getWeatherImage(for sourceText: String) -> UIImage
}

extension GetWeatherImageDelegate {
    func getWeatherImage(for sourceText: String) -> UIImage {
        // List of keywords, sourced from API docs
        // https://docs.google.com/spreadsheets/d/1cc-jQIap7ZToVaEgiXEk_Aa6YVYjSObLV9PMe4oHrFg/edit#gid=1769797687
        let sunnyKeywords = ["sun", "clear"]
        let rainyKeywords = ["rain", "storm"]
        let cloudyKeywords = ["cloud"]
        let snowyKeywords = ["snow"]
        
        // Find whether source text has a keyword, otherwise return default exclamation mark triangle
        for keyword in sunnyKeywords {
            if sourceText.range(of: keyword, options: .caseInsensitive) != nil {
                return UIImage(systemName: "sun.max.fill")!
            }
        }
        
        for keyword in rainyKeywords {
            if sourceText.range(of: keyword, options: .caseInsensitive) != nil {
                return UIImage(systemName: "cloud.rain.fill")!
            }
        }
        
        for keyword in cloudyKeywords {
            if sourceText.range(of: keyword, options: .caseInsensitive) != nil {
                return UIImage(systemName: "cloud.fill")!
            }
        }
        
        for keyword in snowyKeywords {
            if sourceText.range(of: keyword, options: .caseInsensitive) != nil {
                return UIImage(systemName: "cloud.snow.fill")!
            }
        }
        
        return UIImage(systemName: "exclamationmark.triangle")!
    }
}
