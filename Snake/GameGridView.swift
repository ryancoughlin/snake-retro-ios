import SwiftUI

struct GameGridView: View {
    let gameModel: GameModel
    let cellSize: CGFloat
    let gridSpacing: CGFloat
    let nokiaGreen: Color
    let onRestart: () -> Void  // Add this callback
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<GameModel.gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<GameModel.gridSize, id: \.self) { column in
                        let position = Position(x: column, y: row)
                        Rectangle()
                            .fill(cellColor(at: position))
                            .frame(width: cellSize - gridSpacing,
                                   height: cellSize - gridSpacing)
                    }
                }
            }
        }
        .background(nokiaGreen)
        .overlay(
            // Game Over overlay
            Group {
                if gameModel.isGameOver {
                    VStack {
                        Text("GAME OVER")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                        Button("RESTART") {
                            onRestart()  // Call the restart callback
                        }
                        .padding()
                        .background(Color.black)
                        .foregroundColor(nokiaGreen)
                        .cornerRadius(4)
                    }
                    .transition(.opacity)
                }
            }
        )
    }
    
    private func cellColor(at position: Position) -> Color {
        if gameModel.snakePositions.contains(position) {
            return .black
        } else if position == gameModel.foodPosition {
            return .black
        }
        return .clear
    }
}

