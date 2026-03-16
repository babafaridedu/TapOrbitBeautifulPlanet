import Foundation

struct LevelData: Codable {
    var level: Int
    var bestScore: Int
    var attempts: Int
    var successfulTaps: Int
    var totalTaps: Int
    var isUnlocked: Bool
    
    var accuracy: Double {
        guard totalTaps > 0 else { return 0 }
        return Double(successfulTaps) / Double(totalTaps) * 100
    }
}

final class GameDataManager {
    static let shared = GameDataManager()
    
    private let levelsKey = "gameLevelsData"
    private let totalLevels = 15
    
    private init() {
        initializeLevelsIfNeeded()
    }
    
    private func initializeLevelsIfNeeded() {
        if getLevelsData().isEmpty {
            var levels: [LevelData] = []
            for i in 1...totalLevels {
                levels.append(LevelData(
                    level: i,
                    bestScore: 0,
                    attempts: 0,
                    successfulTaps: 0,
                    totalTaps: 0,
                    isUnlocked: i == 1
                ))
            }
            saveLevelsData(levels)
        }
    }
    
    func getLevelsData() -> [LevelData] {
        guard let data = UserDefaults.standard.data(forKey: levelsKey),
              let levels = try? JSONDecoder().decode([LevelData].self, from: data) else {
            return []
        }
        return levels
    }
    
    func saveLevelsData(_ levels: [LevelData]) {
        if let data = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(data, forKey: levelsKey)
        }
    }
    
    func getLevelData(for level: Int) -> LevelData? {
        getLevelsData().first { $0.level == level }
    }
    
    func updateLevelData(level: Int, score: Int, successfulTaps: Int, totalTaps: Int) {
        var levels = getLevelsData()
        guard let index = levels.firstIndex(where: { $0.level == level }) else { return }
        
        levels[index].attempts += 1
        levels[index].successfulTaps += successfulTaps
        levels[index].totalTaps += totalTaps
        
        if score > levels[index].bestScore {
            levels[index].bestScore = score
        }
        
        if level < totalLevels && score >= getRequiredScore(for: level) {
            levels[level].isUnlocked = true
        }
        
        saveLevelsData(levels)
    }
    
    func getRequiredScore(for level: Int) -> Int {
        return level * 5
    }
    
    func getTotalLevels() -> Int {
        return totalLevels
    }
}
