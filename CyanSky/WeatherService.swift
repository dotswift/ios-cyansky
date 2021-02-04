import Foundation
import CoreLocation


struct APIResponse: Decodable {
    let name: String
    let main: APIMain
    let weather: [APIWeather]
}

struct APIMain: Decodable {
    let temp: Double
}

struct APIWeather: Decodable {
    
    let description: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "main"
    }
}


public final class WeatherService: NSObject {
    
    private let locationManager = CLLocationManager()
    private let OPENWEATHER_APIKEY = "2110c5dbe3f236eaab3ae14a09f1eeee"
    private var completionHandler: ((WeatherViewModel)-> Void)?
    
    public func loadWeatherData(_ completionHandler: @escaping ((WeatherViewModel)-> Void)){
        self.completionHandler = completionHandler
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    // api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D){
        guard let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(OPENWEATHER_APIKEY)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            guard error == nil, let data = data else { return }
            
            if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
                self.completionHandler?(WeatherViewModel(response: response))
            }
        }).resume()
    }
    
}
