//
//  WeatherJSONData.swift
//  MyJourney
//
//  Created by Jiawei Liao on 10/5/2024.
//

import Foundation

protocol WeatherProtocol {
    func getWeather(lat: Double, lon: Double, date: Date) async -> String?
}

extension WeatherProtocol {
    func getWeather(lat: Double, lon: Double, date: Date) async -> String? {
        // Convert inputs to string for API call
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let lat = String(lat)
        let lon = String(lon)
        
        // API url creation
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "weather.visualcrossing.com"
        searchURLComponents.path = "/VisualCrossingWebServices/rest/services/timeline/\(lat),\(lon)/\(dateString)"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "key", value: "RPN3MLGNCMD543YBK4XDEV687"),
            URLQueryItem(name: "include", value: "days"),
            URLQueryItem(name: "elements", value: "temp,conditions")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL")
            return nil
        }
        
        // API request
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let weatherData = try decoder.decode(WeatherJSONData.self, from: data)
            
            return weatherData.getWeatherString()
        } catch let error {
            print(error)
            return nil
        }
    }
}

class WeatherJSONData: NSObject, Decodable {
    private enum RootKeys: String, CodingKey {
        case days
    }
    
    private struct WeatherDay: Decodable {
        var temp: Float
        var conditions: String
    }
    
    var temp: String?
    var conditions: String?
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        if let weatherDatas = try? rootContainer.decode([WeatherDay].self, forKey: .days) {
            if let weatherData = weatherDatas.first {
                let tempc = Int(round((weatherData.temp - 32) * 5 / 9))
                temp = String(tempc)
                conditions = weatherData.conditions
            }
        }
    }
    
    func getWeatherString() -> String? {
        return "\(conditions ?? "")\(conditions != nil ? ", " : "")\(temp ?? "")\(temp != nil ? "°C" : "")"
    }
}
