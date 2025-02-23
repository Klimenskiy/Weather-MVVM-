//
//  ViewController.swift
//  Weather
//
//  Created by Klim on 10.01.25.
//

import UIKit

class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()
    private let weatherLabel = UILabel()
    private let fetchWeatherButton = UIButton()
    private let weatherWindSpeedLabel = UILabel()
    private let weatherSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        let labels = [weatherLabel, weatherWindSpeedLabel]
        labels.forEach {
            $0.text = ""
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 24, weight: .bold)
        }

        weatherSearchBar.placeholder = "Enter city name"
        weatherSearchBar.translatesAutoresizingMaskIntoConstraints = false
        weatherSearchBar.delegate = self
        weatherSearchBar.searchBarStyle = .minimal
        weatherSearchBar.tintColor = .black
        weatherSearchBar.layer.cornerRadius = 10
        weatherSearchBar.layer.masksToBounds = true

        fetchWeatherButton.setTitle("My weather", for: .normal)
        fetchWeatherButton.backgroundColor = .systemBlue
        fetchWeatherButton.layer.cornerRadius = 10
        fetchWeatherButton.translatesAutoresizingMaskIntoConstraints = false
        fetchWeatherButton.addTarget(self, action: #selector(fetchWeatherTapped), for: .touchUpInside)

        [weatherLabel, fetchWeatherButton, weatherWindSpeedLabel, weatherSearchBar].forEach {
            view.addSubview($0)
        }

        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            weatherSearchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherSearchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -300),
            weatherSearchBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            weatherSearchBar.heightAnchor.constraint(equalToConstant: 44),

            weatherWindSpeedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherWindSpeedLabel.topAnchor.constraint(equalTo: weatherSearchBar.bottomAnchor, constant: 180),

            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherLabel.topAnchor.constraint(equalTo: weatherWindSpeedLabel.bottomAnchor, constant: padding),

            fetchWeatherButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fetchWeatherButton.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 280),
            fetchWeatherButton.widthAnchor.constraint(equalToConstant: 200),
            fetchWeatherButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func bindViewModel() {
        viewModel.onWeatherUpdate = { [weak self] weatherText, temperature in
            DispatchQueue.main.async {
                self?.showWeatherLabels(weatherText: weatherText, windSpeedText: "") // Плавное обновление
                self?.updateBackgroundColor(for: temperature)
            }
        }
        
        viewModel.onWindUpdate = { [weak self] weatherWindSpeed in
            DispatchQueue.main.async {
                self?.weatherWindSpeedLabel.text = weatherWindSpeed
            }
        }
    }

    
    private func showWeatherLabels(weatherText: String, windSpeedText: String) {
        weatherLabel.alpha = 0
        weatherWindSpeedLabel.alpha = 0
        
        weatherLabel.text = weatherText
        weatherWindSpeedLabel.text = windSpeedText
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.weatherLabel.alpha = 1
            self.weatherWindSpeedLabel.alpha = 1
        })
    }
    
    @objc private func fetchWeatherTapped() {
        viewModel.fetchWeather()
    }
    
 
    
    
    private func updateBackgroundColor(for temperature: Double) {
        let color: UIColor
        
        switch temperature {
        case -50...(-20):
            color = UIColor.systemBlue // Темно-синий
        case -19...0:
            color = UIColor.cyan
        case 1...15:
            color = UIColor.systemYellow
        case 16...30:
            color = UIColor.systemOrange
        case 31...50:
            color = UIColor.systemRed
        default:
            color = UIColor.systemGray // На случай, если нет совпадений
        }
        
        // Плавное изменение фона
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = color
        })
    }

   
}



extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder() // Скрываем клавиатуру
           
           if let city = searchBar.text, !city.isEmpty {
               viewModel.fetchWeather(for: city) // Запрос в ViewModel
           } else {
               weatherLabel.text = "Please enter a city name"
               weatherWindSpeedLabel.isHidden = true
           }
       }
    
}
