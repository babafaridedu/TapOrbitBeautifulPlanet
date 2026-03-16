import UIKit

final class GameOverViewController: UIViewController {
    private let viewModel: GameOverViewModel
    
    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.1, green: 0.0, blue: 0.15, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newBestLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "NEW BEST!"
        return label
    }()
    
    private let scoreContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 64, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bestScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let nextLevelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 20
        return button
    }()
    
    init(score: Int, level: Int) {
        self.viewModel = GameOverViewModel(score: score, level: level)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func setupUI() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(titleLabel)
        view.addSubview(newBestLabel)
        view.addSubview(scoreContainer)
        scoreContainer.addSubview(scoreTitleLabel)
        scoreContainer.addSubview(scoreValueLabel)
        scoreContainer.addSubview(bestScoreLabel)
        view.addSubview(retryButton)
        view.addSubview(nextLevelButton)
        view.addSubview(menuButton)
        
        titleLabel.text = viewModel.gameOverTitle
        scoreTitleLabel.text = viewModel.scoreLabel
        scoreValueLabel.text = "\(viewModel.score)"
        bestScoreLabel.text = "\(viewModel.bestScoreLabel): \(viewModel.bestScore)"
        retryButton.setTitle(viewModel.retryButtonTitle, for: .normal)
        nextLevelButton.setTitle(viewModel.nextLevelButtonTitle, for: .normal)
        menuButton.setTitle(viewModel.menuButtonTitle, for: .normal)
        
        newBestLabel.isHidden = !viewModel.isNewBest
        nextLevelButton.isHidden = !viewModel.canPlayNextLevel
        
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        nextLevelButton.addTarget(self, action: #selector(nextLevelTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            
            newBestLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newBestLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            scoreContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            scoreContainer.widthAnchor.constraint(equalToConstant: 200),
            scoreContainer.heightAnchor.constraint(equalToConstant: 150),
            
            scoreTitleLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreTitleLabel.topAnchor.constraint(equalTo: scoreContainer.topAnchor, constant: 20),
            
            scoreValueLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            scoreValueLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            
            bestScoreLabel.centerXAnchor.constraint(equalTo: scoreContainer.centerXAnchor),
            bestScoreLabel.bottomAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: -15),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: nextLevelButton.topAnchor, constant: -15),
            retryButton.widthAnchor.constraint(equalToConstant: 200),
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            nextLevelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextLevelButton.bottomAnchor.constraint(equalTo: menuButton.topAnchor, constant: -15),
            nextLevelButton.widthAnchor.constraint(equalToConstant: 200),
            nextLevelButton.heightAnchor.constraint(equalToConstant: 50),
            
            menuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            menuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            menuButton.widthAnchor.constraint(equalToConstant: 160),
            menuButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func retryTapped() {
        dismiss(animated: true) {
            guard let nav = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController as? UINavigationController,
                  nav.viewControllers.last is GameplayViewController else { return }
            
            let newGameVC = GameplayViewController(level: self.viewModel.level)
            nav.popViewController(animated: false)
            nav.pushViewController(newGameVC, animated: false)
        }
    }
    
    @objc private func nextLevelTapped() {
        dismiss(animated: true) {
            guard let nav = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController as? UINavigationController else { return }
            
            let newGameVC = GameplayViewController(level: self.viewModel.nextLevel)
            nav.popViewController(animated: false)
            nav.pushViewController(newGameVC, animated: false)
        }
    }
    
    @objc private func menuTapped() {
        dismiss(animated: true) {
            guard let nav = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController as? UINavigationController else { return }
            
            nav.popToRootViewController(animated: true)
        }
    }
}
