import UIKit
import WebKit
import StoreKit

final class ContentDisplayViewController: UIViewController {
    private let contentLink: String
    private let shouldRequestReview: Bool
    private var hasFinishedInitialLoad = false
    
    private lazy var contentView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.allowsBackForwardNavigationGestures = true
        return view
    }()
    
    private let loadingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(link: String, shouldRequestReview: Bool) {
        self.contentLink = link
        self.shouldRequestReview = shouldRequestReview
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
        requestReviewIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setOrientationLock(.all)
    }
    
    private func setOrientationLock(_ orientation: UIInterfaceOrientationMask) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.orientationLock = orientation
        
        guard let windowScene = view.window?.windowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
        windowScene.requestGeometryUpdate(geometryPreferences) { _ in }
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        view.addSubview(loadingContainer)
        loadingContainer.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor)
        ])
        
        loadingIndicator.startAnimating()
    }
    
    private func loadContent() {
        guard let address = URL(string: contentLink) else { return }
        var request = URLRequest(url: address)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        contentView.load(request)
    }
    
    private func requestReviewIfNeeded() {
        guard shouldRequestReview else { return }
        StorageManager.shared.hasRequestedReview = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let windowScene = self?.view.window?.windowScene else { return }
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

extension ContentDisplayViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !hasFinishedInitialLoad {
            hasFinishedInitialLoad = true
            UIView.animate(withDuration: 0.3) {
                self.loadingContainer.alpha = 0
            } completion: { _ in
                self.loadingContainer.isHidden = true
            }
        }
    }
}
