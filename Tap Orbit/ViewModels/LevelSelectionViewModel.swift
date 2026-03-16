import Foundation

final class LevelSelectionViewModel {
    var levels: [LevelData] {
        GameDataManager.shared.getLevelsData()
    }
    
    let screenTitle = "SELECT LEVEL"
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        levels.first { $0.level == level }?.isUnlocked ?? false
    }
    
    func getBestScore(for level: Int) -> Int {
        levels.first { $0.level == level }?.bestScore ?? 0
    }
}
