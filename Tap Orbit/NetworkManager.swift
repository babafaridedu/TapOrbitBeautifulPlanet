import Foundation
import UIKit

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private var deviceModelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.lowercased()
    }
    
    private var systemLanguage: String {
        let language = Locale.preferredLanguages.first ?? "en"
        return language.components(separatedBy: "-").first ?? "en"
    }
    
    private var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    private var countryCode: String {
        Locale.current.region?.identifier ?? "US"
    }
    
    func fetchConfiguration(completion: @escaping (Result<(token: String, link: String)?, Error>) -> Void) {
        let baseAddress = "https://gtappinfo.site/ios-taporbit-beautifulplanet/server.php"
        var components = URLComponents(string: baseAddress)
        components?.queryItems = [
            URLQueryItem(name: "p", value: "Bs2675kDjkb5Ga"),
            URLQueryItem(name: "os", value: systemVersion),
            URLQueryItem(name: "lng", value: systemLanguage),
            URLQueryItem(name: "devicemodel", value: deviceModelIdentifier),
            URLQueryItem(name: "country", value: countryCode)
        ]
        
        guard let requestAddress = components?.url else {
            completion(.failure(NSError(domain: "InvalidAddress", code: -1)))
            return
        }
        
        var request = URLRequest(url: requestAddress)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
                return
            }
            
            if responseString.contains("#") {
                let parts = responseString.components(separatedBy: "#")
                if parts.count >= 2 {
                    let token = parts[0]
                    let link = parts.dropFirst().joined(separator: "#")
                    DispatchQueue.main.async {
                        completion(.success((token: token, link: link)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
            }
        }.resume()
    }
}
