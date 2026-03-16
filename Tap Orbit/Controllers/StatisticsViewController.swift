import UIKit

final class StatisticsViewController: UIViewController {
    private let viewModel = StatisticsViewModel()
    
    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.05, green: 0.0, blue: 0.15, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        return layer
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let totalAttemptsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    private let accuracyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    private let highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.register(StatisticsCell.self, forCellReuseIdentifier: "StatisticsCell")
        return tv
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSummary()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func setupUI() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(summaryContainer)
        summaryContainer.addSubview(totalAttemptsLabel)
        summaryContainer.addSubview(accuracyLabel)
        summaryContainer.addSubview(highScoreLabel)
        view.addSubview(tableView)
        
        titleLabel.text = viewModel.screenTitle
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            summaryContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            summaryContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryContainer.heightAnchor.constraint(equalToConstant: 80),
            
            totalAttemptsLabel.leadingAnchor.constraint(equalTo: summaryContainer.leadingAnchor, constant: 10),
            totalAttemptsLabel.centerYAnchor.constraint(equalTo: summaryContainer.centerYAnchor),
            totalAttemptsLabel.widthAnchor.constraint(equalTo: summaryContainer.widthAnchor, multiplier: 0.3),
            
            accuracyLabel.centerXAnchor.constraint(equalTo: summaryContainer.centerXAnchor),
            accuracyLabel.centerYAnchor.constraint(equalTo: summaryContainer.centerYAnchor),
            accuracyLabel.widthAnchor.constraint(equalTo: summaryContainer.widthAnchor, multiplier: 0.3),
            
            highScoreLabel.trailingAnchor.constraint(equalTo: summaryContainer.trailingAnchor, constant: -10),
            highScoreLabel.centerYAnchor.constraint(equalTo: summaryContainer.centerYAnchor),
            highScoreLabel.widthAnchor.constraint(equalTo: summaryContainer.widthAnchor, multiplier: 0.3),
            
            tableView.topAnchor.constraint(equalTo: summaryContainer.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateSummary() {
        totalAttemptsLabel.text = "Total Attempts\n\(viewModel.totalAttempts)"
        accuracyLabel.text = "Accuracy\n\(String(format: "%.1f", viewModel.overallAccuracy))%"
        highScoreLabel.text = "High Score\n\(viewModel.highestScore)"
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell", for: indexPath) as! StatisticsCell
        let stat = viewModel.statistics[indexPath.row]
        cell.configure(with: stat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

final class StatisticsCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bestScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let attemptsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accuracyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = .white.withAlphaComponent(0.3)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(levelLabel)
        containerView.addSubview(bestScoreLabel)
        containerView.addSubview(attemptsLabel)
        containerView.addSubview(accuracyLabel)
        containerView.addSubview(lockIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            levelLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            levelLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            bestScoreLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 20),
            bestScoreLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            attemptsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 30),
            attemptsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            accuracyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            accuracyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            lockIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 24),
            lockIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with stat: LevelStatistic) {
        levelLabel.text = "Level \(stat.level)"
        
        if stat.isUnlocked {
            bestScoreLabel.text = "Best: \(stat.bestScore)"
            attemptsLabel.text = "Plays: \(stat.attempts)"
            accuracyLabel.text = "\(String(format: "%.0f", stat.accuracy))%"
            
            levelLabel.isHidden = false
            bestScoreLabel.isHidden = false
            attemptsLabel.isHidden = false
            accuracyLabel.isHidden = false
            lockIcon.isHidden = true
        } else {
            levelLabel.isHidden = false
            bestScoreLabel.isHidden = true
            attemptsLabel.isHidden = true
            accuracyLabel.isHidden = true
            lockIcon.isHidden = false
            levelLabel.textColor = .white.withAlphaComponent(0.3)
        }
    }
}
