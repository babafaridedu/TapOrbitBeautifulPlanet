import Foundation

struct LevelStatistic {
    let level: Int
    let bestScore: Int
    let attempts: Int
    let accuracy: Double
    let isUnlocked: Bool
}

final class StatisticsViewModel {
    let screenTitle = "STATISTICS"
    
    var statistics: [LevelStatistic] {
        GameDataManager.shared.getLevelsData().map { data in
            LevelStatistic(
                level: data.level,
                bestScore: data.bestScore,
                attempts: data.attempts,
                accuracy: data.accuracy,
                isUnlocked: data.isUnlocked
            )
        }
    }
    
    var totalAttempts: Int {
        GameDataManager.shared.getLevelsData().reduce(0) { $0 + $1.attempts }
    }
    
    var overallAccuracy: Double {
        let levels = GameDataManager.shared.getLevelsData()
        let totalTaps = levels.reduce(0) { $0 + $1.totalTaps }
        let successfulTaps = levels.reduce(0) { $0 + $1.successfulTaps }
        guard totalTaps > 0 else { return 0 }
        return Double(successfulTaps) / Double(totalTaps) * 100
    }
    
    var highestScore: Int {
        GameDataManager.shared.getLevelsData().max(by: { $0.bestScore < $1.bestScore })?.bestScore ?? 0
    }
}
