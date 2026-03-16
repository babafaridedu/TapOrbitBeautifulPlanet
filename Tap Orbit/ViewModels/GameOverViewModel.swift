import Foundation

final class GameOverViewModel {
    let score: Int
    let level: Int
    let isNewBest: Bool
    
    let gameOverTitle = "GAME OVER"
    let scoreLabel = "SCORE"
    let bestScoreLabel = "BEST"
    let retryButtonTitle = "RETRY"
    let menuButtonTitle = "MENU"
    let nextLevelButtonTitle = "NEXT LEVEL"
    
    var bestScore: Int {
        GameDataManager.shared.getLevelData(for: level)?.bestScore ?? 0
    }
    
    var canPlayNextLevel: Bool {
        let requiredScore = GameDataManager.shared.getRequiredScore(for: level)
        let nextLevel = level + 1
        return score >= requiredScore && nextLevel <= GameDataManager.shared.getTotalLevels()
    }
    
    var nextLevel: Int {
        level + 1
    }
    
    init(score: Int, level: Int) {
        self.score = score
        self.level = level
        let previousBest = GameDataManager.shared.getLevelData(for: level)?.bestScore ?? 0
        self.isNewBest = score > previousBest
    }
}
