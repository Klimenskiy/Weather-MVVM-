//
//  WeatherService.swift
//  Weather
//
//  Created by Klim on 05.02.25.
//

import Foundation
import CoreLocation

class WeatherService {
    private let baseURL = "https://api.open-meteo.com"
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(weatherResponse)
            } catch {
                print("Ошибка декодирования: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
