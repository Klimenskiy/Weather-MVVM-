import Foundation
import CoreLocation

class WeatherViewModel: NSObject, CLLocationManagerDelegate {
    private let weatherService = WeatherService() // Сервис для получения погоды
    private var locationManager = CLLocationManager() // Объект для работы с местоположением
    
    var onWeatherUpdate: ((String, Double) -> Void)? // Обработчик обновления погоды
    var onWindUpdate: ((String) -> Void)? // Обработчик обновления скорости ветра

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Location-based Weather
    
    func fetchWeather() {
        locationManager.requestLocation() 
    }

    private func updateWeather(for location: CLLocation) {
        weatherService.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] weatherResponse in
            guard let weatherResponse = weatherResponse else {
                self?.onWeatherUpdate?("Не удалось загрузить погоду", 0.0)
                return
            }
            self?.updateWeatherUI(with: weatherResponse)
        }
    }
    
    // MARK: - City-based Weather
    
    func fetchWeather(for city: String) {
        let urlString = "https://api.weatherstack.com/current?access_key=78f3db679cda6a5aebc437acf5bd4fbe&query=\(city.replacingOccurrences(of: " ", with: "%20"))"
        guard let url = URL(string: urlString) else {
            onWeatherUpdate?("Invalid city name", 0.0)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                self?.onWeatherUpdate?("Network error", 0.0)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                
                if json["error"] != nil {
                    DispatchQueue.main.async {
                        self?.onWeatherUpdate?("City not found", 0.0)
                    }
                    return
                }
                
                if let current = json["current"] {
                    let windSpeed = current["wind_speed"] as? Double ?? 0.0
                    let temperature = current["temperature"] as? Double ?? 0.0
                    
                    DispatchQueue.main.async {
                        self?.onWeatherUpdate?("Temperature: \(temperature)°C", temperature)
                        self?.onWindUpdate?("Wind speed: \(windSpeed) km/h")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.onWeatherUpdate?("Failed to decode weather data", 0.0)
                }
            }
        }.resume()
    }
    
    // MARK: - Private
    
    private func updateWeatherUI(with weatherResponse: WeatherResponse) {
        let temperature = weatherResponse.currentWeather.temperature
        let weatherText = "Temperature: \(temperature)°C"
        let windSpeed = weatherResponse.currentWeather.windspeed
        let weatherWindSpeed = "Wind speed: \(windSpeed) km/h"
        
        DispatchQueue.main.async {
            self.onWeatherUpdate?(weatherText, temperature)
            self.onWindUpdate?(weatherWindSpeed)
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            updateWeather(for: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onWeatherUpdate?("Не удалось определить местоположение", 0.0)
    }
}
