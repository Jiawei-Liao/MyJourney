//
//  GeocodingJSONData.swift
//  MyJourney
//
//  Created by Jiawei Liao on 9/5/2024.
//

import Foundation
import MapKit

protocol GeocodingProtocol {
    func getAddress(lat: Double, lon: Double) async -> String?
}

extension GeocodingProtocol {
    func getAddress(lat: Double, lon: Double) async -> String? {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "geocode.maps.co"
        searchURLComponents.path = "/reverse"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "api_key", value: "663c8bc51d308914279630vogb80164")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL")
            return nil
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let addressData = try decoder.decode(GeocodingJSONData.self, from: data)
            
            return addressData.getAddressName()
        } catch let error {
            print(error)
            return nil
        }
    }
}

class GeocodingJSONData: NSObject, Decodable {
    private enum RootKeys: String, CodingKey {
        case address
    }
    
    private enum AddressKeys: String, CodingKey {
        case house_number
        case road
        case suburb
        case city
        case state
        case country
    }
    
    var house_number: String?
    var road: String?
    var suburb: String?
    var city: String?
    var state: String?
    var country: String?
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        let addressContainer = try rootContainer.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)
        
        house_number = try? addressContainer.decode(String.self, forKey: .house_number)
        road = try? addressContainer.decode(String.self, forKey: .road)
        suburb = try? addressContainer.decode(String.self, forKey: .suburb)
        city = try? addressContainer.decode(String.self, forKey: .city)
        state = try? addressContainer.decode(String.self, forKey: .state)
        country = try? addressContainer.decode(String.self, forKey: .country)
        
    }
    
    func getAddressName() -> String? {
        return "\(house_number ?? "")\(house_number != nil ? " " : "")\(road ?? "")\(road != nil ? ", " : "")\(suburb ?? "")\(suburb != nil ? ", " : "")\(city ?? "")\(city != nil ? " " : "")\(state ?? "")\(state != nil ? ", " : "")\(country ?? "")"
    }
}
