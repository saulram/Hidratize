import Foundation
import CoreLocation

class WeatherService {
    private let apiKey = Config.Keys.weatherApiKey

    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL inválida", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Datos no recibidos", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
