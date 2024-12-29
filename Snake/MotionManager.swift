import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let updateInterval = 0.1
    
    @Published var direction: Direction = .right
    
    var isDeviceMotionAvailable: Bool {
        return motionManager.isAccelerometerAvailable
    }
    
    init() {
        motionManager.accelerometerUpdateInterval = updateInterval
    }
    
    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            
            // Reduced threshold for more sensitive controls
            let threshold: Double = 0.2
            
            if abs(data.acceleration.x) > abs(data.acceleration.y) {
                // Horizontal tilt is stronger
                if data.acceleration.x > threshold {
                    self?.direction = .right
                } else if data.acceleration.x < -threshold {
                    self?.direction = .left
                }
            } else {
                // Vertical tilt is stronger
                if data.acceleration.y > threshold {
                    self?.direction = .down
                } else if data.acceleration.y < -threshold {
                    self?.direction = .up
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
