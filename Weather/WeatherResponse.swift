//
//  Model.swift
//  Weather
//
//  Created by Klim on 04.02.25.
//

struct WeatherResponse: Codable {
    let currentWeather: CurrentWeather

    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
}

struct CurrentWeather: Codable {
    let time: String
    let temperature: Double
    let windspeed: Double
    let winddirection: Double
    let isDay: Int
    

    enum CodingKeys: String, CodingKey {
        case time
        case temperature
        case windspeed
        case winddirection
        case isDay = "is_day"
        
    }
}
