import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let tokenKey = "savedAccessToken"
    private let linkKey = "savedContentLink"
    private let reviewRequestedKey = "hasRequestedReview"
    
    private init() {}
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }
    
    var contentLink: String? {
        get { UserDefaults.standard.string(forKey: linkKey) }
        set { UserDefaults.standard.set(newValue, forKey: linkKey) }
    }
    
    var hasStoredToken: Bool {
        accessToken != nil && contentLink != nil
    }
    
    var hasRequestedReview: Bool {
        get { UserDefaults.standard.bool(forKey: reviewRequestedKey) }
        set { UserDefaults.standard.set(newValue, forKey: reviewRequestedKey) }
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: linkKey)
    }
}
