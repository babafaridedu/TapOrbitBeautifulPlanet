import UIKit

final class MainMenuViewController: UIViewController {
    private let viewModel = MainMenuViewModel()
    
    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.05, green: 0.0, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        layer.locations = [0.0, 0.5, 1.0]
        return layer
    }()
    
    private let planetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 60
        return view
    }()
    
    private let orbitView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 100
        return view
    }()
    
    private let orbitingBall: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let statisticsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startOrbitAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func setupUI() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(orbitView)
        view.addSubview(planetView)
        view.addSubview(orbitingBall)
        view.addSubview(titleLabel)
        view.addSubview(startButton)
        view.addSubview(statisticsButton)
        
        titleLabel.text = viewModel.gameTitle
        startButton.setTitle(viewModel.startButtonTitle, for: .normal)
        statisticsButton.setTitle(viewModel.statisticsButtonTitle, for: .normal)
        
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        statisticsButton.addTarget(self, action: #selector(statisticsTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            orbitView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orbitView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            orbitView.widthAnchor.constraint(equalToConstant: 200),
            orbitView.heightAnchor.constraint(equalToConstant: 200),
            
            planetView.centerXAnchor.constraint(equalTo: orbitView.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: orbitView.centerYAnchor),
            planetView.widthAnchor.constraint(equalToConstant: 120),
            planetView.heightAnchor.constraint(equalToConstant: 120),
            
            orbitingBall.widthAnchor.constraint(equalToConstant: 20),
            orbitingBall.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: statisticsButton.topAnchor, constant: -20),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            statisticsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            statisticsButton.widthAnchor.constraint(equalToConstant: 180),
            statisticsButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        addStars()
    }
    
    private func addStars() {
        for _ in 0..<50 {
            let star = UIView()
            star.backgroundColor = .white
            star.alpha = CGFloat.random(in: 0.3...0.8)
            let size = CGFloat.random(in: 1...3)
            star.frame = CGRect(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: CGFloat.random(in: 0...view.bounds.height),
                width: size,
                height: size
            )
            star.layer.cornerRadius = size / 2
            view.insertSubview(star, at: 1)
        }
    }
    
    private func startOrbitAnimation() {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 100)
        let radius: CGFloat = 100
        
        orbitingBall.center = CGPoint(x: center.x + radius, y: center.y)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        animation.path = path.cgPath
        animation.duration = 3
        animation.repeatCount = .infinity
        animation.calculationMode = .paced
        orbitingBall.layer.add(animation, forKey: "orbit")
    }
    
    @objc private func startTapped() {
        let vc = LevelSelectionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func statisticsTapped() {
        let vc = StatisticsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
