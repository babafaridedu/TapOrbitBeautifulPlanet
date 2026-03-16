import UIKit

final class GameplayViewController: UIViewController {
    private var viewModel: GameViewModel
    
    private let backgroundGradient = CAGradientLayer()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let targetScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemYellow.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let planetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orbitLayer = CAShapeLayer()
    private var zoneShapeLayers: [CAShapeLayer] = []
    private let orbitingBall: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.shadowColor = UIColor.orange.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = .zero
        return view
    }()
    
    private var displayLink: CADisplayLink?
    private var ballAngle: CGFloat = 0
    private var zoneAngles: [(start: CGFloat, end: CGFloat)] = []
    private var orbitCenter: CGPoint = .zero
    private var orbitRadius: CGFloat = 120
    private let ballRadius: CGFloat = 12
    private let planetRadius: CGFloat = 50
    
    init(level: Int) {
        self.viewModel = GameViewModel(level: level)
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
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        orbitCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        planetView.layer.cornerRadius = planetRadius
        setupOrbit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGame()
    }
    
    private func setupUI() {
        setupLevelTheme()
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(scoreLabel)
        view.addSubview(levelLabel)
        view.addSubview(targetScoreLabel)
        view.addSubview(planetView)
        view.addSubview(orbitingBall)
        
        levelLabel.text = "LEVEL \(viewModel.currentLevel)"
        
        let requiredScore = viewModel.getRequiredScoreToUnlock()
        let totalLevels = GameDataManager.shared.getTotalLevels()
        if viewModel.currentLevel < totalLevels {
            targetScoreLabel.text = "Next level: \(requiredScore) pts"
        } else {
            targetScoreLabel.text = "Final level!"
        }
        
        orbitingBall.frame = CGRect(x: 0, y: 0, width: ballRadius * 2, height: ballRadius * 2)
        orbitingBall.layer.cornerRadius = ballRadius
        
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            targetScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            targetScoreLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            
            planetView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planetView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            planetView.widthAnchor.constraint(equalToConstant: planetRadius * 2),
            planetView.heightAnchor.constraint(equalToConstant: planetRadius * 2)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        addStars()
    }
    
    private func setupLevelTheme() {
        let theme = getLevelTheme(for: viewModel.currentLevel)
        backgroundGradient.colors = theme.gradientColors
        planetView.backgroundColor = theme.planetColor
        orbitingBall.backgroundColor = theme.ballColor
        orbitingBall.layer.shadowColor = theme.ballColor.cgColor
    }
    
    private func getLevelTheme(for level: Int) -> (gradientColors: [CGColor], planetColor: UIColor, ballColor: UIColor) {
        switch level {
        case 1:
            return (
                [UIColor(red: 0.02, green: 0.0, blue: 0.12, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
                UIColor.systemOrange
            )
        case 2:
            return (
                [UIColor(red: 0.0, green: 0.08, blue: 0.12, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 0.02, blue: 0.05, alpha: 1.0).cgColor],
                UIColor(red: 0.1, green: 0.5, blue: 0.6, alpha: 1.0),
                UIColor.systemYellow
            )
        case 3:
            return (
                [UIColor(red: 0.1, green: 0.0, blue: 0.15, alpha: 1.0).cgColor, UIColor(red: 0.02, green: 0.0, blue: 0.05, alpha: 1.0).cgColor],
                UIColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0),
                UIColor.systemPink
            )
        case 4:
            return (
                [UIColor(red: 0.08, green: 0.05, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.02, green: 0.01, blue: 0.0, alpha: 1.0).cgColor],
                UIColor(red: 0.7, green: 0.4, blue: 0.2, alpha: 1.0),
                UIColor.systemRed
            )
        case 5:
            return (
                [UIColor(red: 0.0, green: 0.1, blue: 0.05, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 0.03, blue: 0.02, alpha: 1.0).cgColor],
                UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0),
                UIColor.systemCyan
            )
        case 6:
            return (
                [UIColor(red: 0.12, green: 0.0, blue: 0.08, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.8, green: 0.2, blue: 0.4, alpha: 1.0),
                UIColor.systemMint
            )
        case 7:
            return (
                [UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0).cgColor, UIColor(red: 0.02, green: 0.02, blue: 0.04, alpha: 1.0).cgColor],
                UIColor(red: 0.4, green: 0.4, blue: 0.7, alpha: 1.0),
                UIColor.white
            )
        case 8:
            return (
                [UIColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0).cgColor, UIColor(red: 0.03, green: 0.01, blue: 0.0, alpha: 1.0).cgColor],
                UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0),
                UIColor.systemIndigo
            )
        case 9:
            return (
                [UIColor(red: 0.0, green: 0.05, blue: 0.1, alpha: 1.0).cgColor, UIColor(red: 0.0, green: 0.02, blue: 0.04, alpha: 1.0).cgColor],
                UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0),
                UIColor.systemGreen
            )
        case 10:
            return (
                [UIColor(red: 0.08, green: 0.0, blue: 0.1, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.6, green: 0.1, blue: 0.6, alpha: 1.0),
                UIColor.systemYellow
            )
        case 11:
            return (
                [UIColor(red: 0.0, green: 0.08, blue: 0.08, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.2, green: 0.7, blue: 0.7, alpha: 1.0),
                UIColor.systemOrange
            )
        case 12:
            return (
                [UIColor(red: 0.1, green: 0.02, blue: 0.02, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0),
                UIColor.systemTeal
            )
        case 13:
            return (
                [UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
                UIColor.systemPurple
            )
        case 14:
            return (
                [UIColor(red: 0.08, green: 0.04, blue: 0.1, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1.0),
                UIColor.systemBlue
            )
        case 15:
            return (
                [UIColor(red: 0.15, green: 0.0, blue: 0.0, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),
                UIColor.white
            )
        default:
            return (
                [UIColor(red: 0.02, green: 0.0, blue: 0.08, alpha: 1.0).cgColor, UIColor.black.cgColor],
                UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
                UIColor.systemOrange
            )
        }
    }
    
    private func addStars() {
        for _ in 0..<80 {
            let star = UIView()
            star.backgroundColor = .white
            star.alpha = CGFloat.random(in: 0.2...0.6)
            let size = CGFloat.random(in: 1...2)
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
    
    private func setupOrbit() {
        orbitLayer.removeFromSuperlayer()
        zoneShapeLayers.forEach { $0.removeFromSuperlayer() }
        zoneShapeLayers.removeAll()
        
        let orbitPath = UIBezierPath(arcCenter: orbitCenter, radius: orbitRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        orbitLayer.path = orbitPath.cgPath
        orbitLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        orbitLayer.fillColor = UIColor.clear.cgColor
        orbitLayer.lineWidth = 2
        view.layer.insertSublayer(orbitLayer, at: 1)
        
        generateZones()
    }
    
    private func generateZones() {
        zoneShapeLayers.forEach { $0.removeFromSuperlayer() }
        zoneShapeLayers.removeAll()
        zoneAngles.removeAll()
        
        let zoneCount = viewModel.zoneCount
        let zoneSize = CGFloat(viewModel.zoneSize) * .pi * 2
        
        for i in 0..<zoneCount {
            let baseAngle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let offset = CGFloat(i) * (.pi * 2 / CGFloat(zoneCount))
            let startAngle = (baseAngle + offset).truncatingRemainder(dividingBy: .pi * 2)
            let endAngle = startAngle + zoneSize
            
            zoneAngles.append((start: startAngle, end: endAngle))
            
            let zoneLayer = CAShapeLayer()
            let zonePath = UIBezierPath(arcCenter: orbitCenter, radius: orbitRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            zoneLayer.path = zonePath.cgPath
            zoneLayer.strokeColor = UIColor.systemGreen.cgColor
            zoneLayer.fillColor = UIColor.clear.cgColor
            zoneLayer.lineWidth = 8
            zoneLayer.lineCap = .round
            zoneLayer.shadowColor = UIColor.green.cgColor
            zoneLayer.shadowRadius = 6
            zoneLayer.shadowOpacity = 0.6
            zoneLayer.shadowOffset = .zero
            view.layer.insertSublayer(zoneLayer, above: orbitLayer)
            zoneShapeLayers.append(zoneLayer)
        }
    }
    
    private func bindViewModel() {
        viewModel.onScoreUpdate = { [weak self] score in
            self?.scoreLabel.text = "\(score)"
        }
        
        viewModel.onSpeedIncrease = { [weak self] in
            self?.generateZones()
        }
        
        viewModel.onGameOver = { [weak self] score, level in
            self?.showGameOver(score: score, level: level)
        }
    }
    
    private func startGame() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBallPosition))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopGame() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateBallPosition() {
        let speed = CGFloat(viewModel.currentSpeed)
        ballAngle += (displayLink?.duration ?? 0.016) * (2 * .pi / speed)
        if ballAngle > .pi * 2 {
            ballAngle -= .pi * 2
        }
        
        let x = orbitCenter.x + orbitRadius * cos(ballAngle)
        let y = orbitCenter.y + orbitRadius * sin(ballAngle)
        orbitingBall.center = CGPoint(x: x, y: y)
    }
    
    @objc private func handleTap() {
        let isInZone = zoneAngles.contains { zone in
            var normalizedBallAngle = ballAngle
            let start = zone.start
            var end = zone.end
            
            if end > .pi * 2 {
                end -= .pi * 2
                if normalizedBallAngle < start {
                    normalizedBallAngle += .pi * 2
                }
                end += .pi * 2
            }
            
            return normalizedBallAngle >= start && normalizedBallAngle <= end
        }
        
        viewModel.handleTap(isInZone: isInZone)
    }
    
    private func showGameOver(score: Int, level: Int) {
        stopGame()
        let vc = GameOverViewController(score: score, level: level)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
