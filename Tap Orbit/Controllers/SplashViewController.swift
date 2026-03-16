import UIKit

final class SplashViewController: UIViewController {
    private let viewModel = SplashViewModel()
    private var hasCheckedState = false
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TAP ORBIT"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasCheckedState else { return }
        hasCheckedState = true
        viewModel.checkInitialState()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(titleLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40)
        ])
        
        activityIndicator.startAnimating()
    }
    
    private func bindViewModel() {
        viewModel.onDestinationReady = { [weak self] destination in
            self?.navigateToDestination(destination)
        }
    }
    
    private func navigateToDestination(_ destination: AppLaunchDestination) {
        switch destination {
        case .contentDisplay(let link, let shouldRequestReview):
            let vc = ContentDisplayViewController(link: link, shouldRequestReview: shouldRequestReview)
            setRootViewController(vc)
        case .mainMenu:
            let vc = MainMenuViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.setNavigationBarHidden(true, animated: false)
            setRootViewController(nav)
        }
    }
    
    private func setRootViewController(_ vc: UIViewController) {
        guard let window = view.window else { return }
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
