import SwiftUI

struct GameView: View {
    @StateObject private var gameModel = GameModel()
    @StateObject private var motionManager = MotionManager()
    @State private var timer: Timer?
    
    private let gridSpacing: CGFloat = 1
    private let nokiaGreen = Color(red: 0.7, green: 0.85, blue: 0.1)
    private let topBarHeight: CGFloat = 50 // Height for score and level display
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate the game area size
            let gameAreaWidth = geometry.size.width
            let gameAreaHeight = geometry.size.height - topBarHeight
            let cellSize = min(
                gameAreaWidth / CGFloat(GameModel.gridSize),
                gameAreaHeight / CGFloat(GameModel.gridSize)
            )
            
            ZStack {
                // Background
                nokiaGreen
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top bar with score and level
                    HStack {
                        Text(String(format: "Score: %04d", gameModel.score))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                        Spacer()
                        Text("Level: \(gameModel.currentLevel)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .frame(height: topBarHeight)
                    .padding(.horizontal)
                    
                    // Game grid area
                    GameGridView(
                        gameModel: gameModel,
                        cellSize: cellSize,
                        gridSpacing: gridSpacing,
                        nokiaGreen: nokiaGreen,
                        onRestart: restartGame  // Add onRestart parameter
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Arrow Controls for Simulator at the bottom
                    if !motionManager.isDeviceMotionAvailable {
                        HStack(spacing: 20) {
                            ForEach(["←", "↑", "↓", "→"], id: \.self) { arrow in
                                Button(action: {
                                    switch arrow {
                                    case "←": gameModel.currentDirection = .left
                                    case "→": gameModel.currentDirection = .right
                                    case "↑": gameModel.currentDirection = .up
                                    case "↓": gameModel.currentDirection = .down
                                    default: break
                                    }
                                }) {
                                    Text(arrow)
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(width: 44, height: 44)
                                        .background(Color.black)
                                        .foregroundColor(nokiaGreen)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
        .onChange(of: motionManager.direction) { newDirection in
            gameModel.currentDirection = newDirection
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func startGame() {
        motionManager.startUpdates()
        scheduleTimer()
    }
    
    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: gameModel.updateInterval, repeats: true) { _ in
            withAnimation {
                gameModel.move()
            }
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        timer = nil
        motionManager.stopUpdates()
    }
    
    // Add restartGame function
    private func restartGame() {
        gameModel.isGameOver = false
        gameModel.score = 0
        gameModel.currentLevel = 1
        gameModel.snakePositions = [Position(x: GameModel.gridSize / 2, y: GameModel.gridSize / 2)]
        gameModel.foodPosition = GameModel.generateRandomPosition()
        gameModel.currentDirection = .right
        startGame()
    }
}
