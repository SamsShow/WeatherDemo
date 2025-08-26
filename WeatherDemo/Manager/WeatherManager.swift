import Foundation
import CoreLocation

class WeatherManager {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=APIKEY&units=metric") else {
            throw NSError(domain: "Invalid URL", code: 100, userInfo: nil)
        }
        
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTP Error", code: 101, userInfo: nil)
        }
        
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        return decodedData
    }
    
    // MARK: - Model
    struct ResponseBody: Decodable {
        var coord: CoordinatesResponse
        var weather: [WeatherResponse]
        var main: MainResponse
        var name: String
        var wind: WindResponse
        
        struct CoordinatesResponse: Decodable {
            var lon: Double
            var lat: Double
        }
        
        struct WeatherResponse: Decodable {
            var id: Int
            var main: String
            var description: String
            var icon: String
        }
        
        struct MainResponse: Decodable {
            var temp: Double
            var feels_like: Double
            var temp_min: Double
            var temp_max: Double
            var pressure: Double
            var humidity: Double
        }
        
        struct WindResponse: Decodable {
            var speed: Double
            var deg: Double
        }
    }
}

// Extension outside the class
extension WeatherManager.ResponseBody.MainResponse {
    var feelsLike: Double { feels_like }
    var tempMin: Double { temp_min }
    var tempMax: Double { temp_max }
}
