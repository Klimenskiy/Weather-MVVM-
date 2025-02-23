import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Создаем основное окно
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        // Создаем SwiftUI SplashScreen
        let splashScreen = UIHostingController(rootView: SplashScreenView())
        window.rootViewController = splashScreen
        window.makeKeyAndVisible()
        
        // Задержка для отображения SplashScreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            // Переход на WeatherViewController
            let mainViewController = WeatherViewController()
            self?.window?.rootViewController = mainViewController
        }

        return true
    }
}
