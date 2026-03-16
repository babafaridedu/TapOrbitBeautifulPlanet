import Foundation

final class GameViewModel {
    private(set) var currentLevel: Int
    private(set) var score: Int = 0
    private(set) var successfulTaps: Int = 0
    private(set) var totalTaps: Int = 0
    
    var onScoreUpdate: ((Int) -> Void)?
    var onGameOver: ((Int, Int) -> Void)?
    var onSpeedIncrease: (() -> Void)?
    
    var baseSpeed: Double {
        return 2.0 - Double(currentLevel - 1) * 0.08
    }
    
    var currentSpeed: Double {
        let speedMultiplier = 1.0 + Double(score) * 0.05
        return baseSpeed / speedMultiplier
    }
    
    var zoneCount: Int {
        if currentLevel >= 10 && score >= 10 {
            return 2
        } else if currentLevel >= 5 && score >= 5 {
            return Int.random(in: 1...2)
        }
        return 1
    }
    
    var zoneSize: Double {
        let baseSize = 0.15 - Double(currentLevel - 1) * 0.005
        return max(0.08, baseSize)
    }
    
    init(level: Int) {
        self.currentLevel = level
    }
    
    func handleTap(isInZone: Bool) {
        totalTaps += 1
        
        if isInZone {
            score += 1
            successfulTaps += 1
            onScoreUpdate?(score)
            onSpeedIncrease?()
        } else {
            endGame()
        }
    }
    
    func endGame() {
        GameDataManager.shared.updateLevelData(
            level: currentLevel,
            score: score,
            successfulTaps: successfulTaps,
            totalTaps: totalTaps
        )
        onGameOver?(score, currentLevel)
    }
    
    func getRequiredScoreToUnlock() -> Int {
        GameDataManager.shared.getRequiredScore(for: currentLevel)
    }
}
