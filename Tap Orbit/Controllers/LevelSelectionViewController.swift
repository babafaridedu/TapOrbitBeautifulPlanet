import UIKit

final class LevelSelectionViewController: UIViewController {
    private let viewModel = LevelSelectionViewModel()
    
    private let backgroundGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.05, green: 0.0, blue: 0.15, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(LevelCell.self, forCellWithReuseIdentifier: "LevelCell")
        return cv
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    private func setupUI() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        
        titleLabel.text = viewModel.screenTitle
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension LevelSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        let level = viewModel.levels[indexPath.item]
        cell.configure(level: level.level, bestScore: level.bestScore, isUnlocked: level.isUnlocked)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 90) / 3
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = viewModel.levels[indexPath.item]
        guard level.isUnlocked else { return }
        
        let vc = GameplayViewController(level: level.level)
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class LevelCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = .white.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(levelLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(lockIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            levelLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10),
            
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 5),
            
            lockIcon.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 30),
            lockIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(level: Int, bestScore: Int, isUnlocked: Bool) {
        levelLabel.text = "\(level)"
        scoreLabel.text = bestScore > 0 ? "Best: \(bestScore)" : ""
        
        if isUnlocked {
            containerView.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
            levelLabel.isHidden = false
            scoreLabel.isHidden = false
            lockIcon.isHidden = true
        } else {
            containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
            levelLabel.isHidden = true
            scoreLabel.isHidden = true
            lockIcon.isHidden = false
        }
    }
}
