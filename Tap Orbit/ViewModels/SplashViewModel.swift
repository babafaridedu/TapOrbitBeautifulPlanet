import Foundation

enum AppLaunchDestination {
    case contentDisplay(link: String, shouldRequestReview: Bool)
    case mainMenu
}

final class SplashViewModel {
    var onDestinationReady: ((AppLaunchDestination) -> Void)?
    var onError: ((String) -> Void)?
    
    func checkInitialState() {
        if StorageManager.shared.hasStoredToken, let link = StorageManager.shared.contentLink {
            let shouldRequestReview = !StorageManager.shared.hasRequestedReview
            onDestinationReady?(.contentDisplay(link: link, shouldRequestReview: shouldRequestReview))
        } else {
            fetchServerConfiguration()
        }
    }
    
    private func fetchServerConfiguration() {
        NetworkManager.shared.fetchConfiguration { [weak self] result in
            switch result {
            case .success(let config):
                if let config = config {
                    StorageManager.shared.accessToken = config.token
                    StorageManager.shared.contentLink = config.link
                    self?.onDestinationReady?(.contentDisplay(link: config.link, shouldRequestReview: false))
                } else {
                    self?.onDestinationReady?(.mainMenu)
                }
            case .failure:
                self?.onDestinationReady?(.mainMenu)
            }
        }
    }
}
