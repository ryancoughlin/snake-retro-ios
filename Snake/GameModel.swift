import Foundation
import CoreGraphics

enum Direction {
    case up, down, left, right
    
    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

struct Position: Equatable {
    var x: Int
    var y: Int
}

class GameModel: ObservableObject {
    static let gridSize = 20
    
    @Published var snakePositions: [Position] = []
    @Published var foodPosition: Position
    @Published var currentDirection: Direction = .right
    @Published var isGameOver = false
    @Published var score = 0
    @Published var currentLevel: Int = 1
    
    private var lastDirection: Direction = .right
    private var baseUpdateInterval: TimeInterval = 0.2
    
    var updateInterval: TimeInterval {
        let speedIncrease = min(Double(currentLevel - 1) * 0.1, 1.0)
        return baseUpdateInterval * (1.0 - speedIncrease)
    }
    
    init() {
        // Start with snake in middle
        let centerX = GameModel.gridSize / 2
        let centerY = GameModel.gridSize / 2
        snakePositions = [
            Position(x: centerX, y: centerY),
            Position(x: centerX - 1, y: centerY),
            Position(x: centerX - 2, y: centerY)
        ]
        
        // Place food randomly
        foodPosition = Self.generateRandomPosition()
        currentLevel = 1
    }
    
    static func generateRandomPosition() -> Position {
        Position(
            x: Int.random(in: 0..<gridSize),
            y: Int.random(in: 0..<gridSize)
        )
    }
    
    func move() {
        guard !isGameOver else { return }
        
        // Prevent moving in opposite direction
        if currentDirection != lastDirection.opposite {
            lastDirection = currentDirection
        } else {
            currentDirection = lastDirection
        }
        
        var newHead = snakePositions[0]
        
        // Update position based on direction
        switch currentDirection {
        case .up:
            newHead.y = (newHead.y - 1 + GameModel.gridSize) % GameModel.gridSize
        case .down:
            newHead.y = (newHead.y + 1) % GameModel.gridSize
        case .left:
            newHead.x = (newHead.x - 1 + GameModel.gridSize) % GameModel.gridSize
        case .right:
            newHead.x = (newHead.x + 1) % GameModel.gridSize
        }
        
        // Check for collision with self (excluding tail which will move)
        if snakePositions.dropLast().contains(newHead) {
            isGameOver = true
            return
        }
        
        snakePositions.insert(newHead, at: 0)
        
        // Check if food was eaten
        if newHead == foodPosition {
            score += 1
            currentLevel = (score / 5) + 1
            // Generate new food position that's not on snake
            repeat {
                foodPosition = Self.generateRandomPosition()
            } while snakePositions.contains(foodPosition)
        } else {
            snakePositions.removeLast()
        }
    }
}
