import SpriteKit

class GameCamera: SKCameraNode {
    
    var target: SKNode?
    var followSpeed: CGFloat = 0.1
    var deadZone: CGRect = CGRect(x: -50, y: -50, width: 100, height: 100)
    
    // Camera bounds (to prevent showing empty areas) - updated for extended level
    var minX: CGFloat = -4000
    var maxX: CGFloat = 8000
    var minY: CGFloat = -300
    var maxY: CGFloat = 500
    
    // Smooth following variables
    private var targetPosition = CGPoint.zero
    
    func follow(_ node: SKNode) {
        target = node
        targetPosition = node.position
    }
    
    func update() {
        guard let target = target else { return }
        
        // Calculate the desired camera position
        var desiredPosition = target.position
        
        // Apply dead zone logic
        let currentOffset = CGPoint(
            x: position.x - target.position.x,
            y: position.y - target.position.y
        )
        
        // Only move camera if target is outside the dead zone
        if !deadZone.contains(currentOffset) {
            // Horizontal movement
            if currentOffset.x < deadZone.minX {
                desiredPosition.x = target.position.x + deadZone.minX
            } else if currentOffset.x > deadZone.maxX {
                desiredPosition.x = target.position.x + deadZone.maxX
            } else {
                desiredPosition.x = position.x
            }
            
            // Vertical movement (more restrictive)
            if currentOffset.y < deadZone.minY {
                desiredPosition.y = target.position.y + deadZone.minY
            } else if currentOffset.y > deadZone.maxY {
                desiredPosition.y = target.position.y + deadZone.maxY
            } else {
                desiredPosition.y = position.y
            }
        } else {
            desiredPosition = position
        }
        
        // Apply camera bounds
        desiredPosition.x = max(minX, min(maxX, desiredPosition.x))
        desiredPosition.y = max(minY, min(maxY, desiredPosition.y))
        
        // Smooth interpolation to desired position
        targetPosition.x += (desiredPosition.x - targetPosition.x) * followSpeed
        targetPosition.y += (desiredPosition.y - targetPosition.y) * followSpeed
        
        position = targetPosition
    }
    
    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        let shakeAction = SKAction.sequence([
            SKAction.moveBy(x: intensity, y: 0, duration: 0.05),
            SKAction.moveBy(x: -intensity * 2, y: 0, duration: 0.05),
            SKAction.moveBy(x: intensity * 2, y: 0, duration: 0.05),
            SKAction.moveBy(x: -intensity, y: 0, duration: 0.05)
        ])
        
        let repeatShake = SKAction.repeat(shakeAction, count: Int(duration / 0.2))
        run(repeatShake)
    }
    
    func zoomTo(scale: CGFloat, duration: TimeInterval = 1.0) {
        let zoomAction = SKAction.scale(to: scale, duration: duration)
        run(zoomAction)
    }
    
    func panTo(position: CGPoint, duration: TimeInterval = 2.0) {
        let panAction = SKAction.move(to: position, duration: duration)
        run(panAction)
    }
    
    // MARK: - Camera Effects
    
    func focusOnArea(center: CGPoint, size: CGSize, duration: TimeInterval = 1.0) {
        // Temporarily stop following the target
        let originalTarget = target
        target = nil
        
        // Calculate zoom level to fit the area
        guard let scene = scene else { return }
        let scaleX = scene.size.width / size.width
        let scaleY = scene.size.height / size.height
        let scale = min(scaleX, scaleY) * 0.8 // Add some padding
        
        // Pan and zoom to the area
        let panAction = SKAction.move(to: center, duration: duration)
        let zoomAction = SKAction.scale(to: scale, duration: duration)
        let focusAction = SKAction.group([panAction, zoomAction])
        
        // Return to following after the focus
        let returnAction = SKAction.run {
            self.target = originalTarget
            self.zoomTo(scale: 1.0, duration: 0.5)
        }
        
        let sequence = SKAction.sequence([focusAction, SKAction.wait(forDuration: 1.0), returnAction])
        run(sequence)
    }
    
    func setBounds(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    func setDeadZone(width: CGFloat, height: CGFloat) {
        deadZone = CGRect(x: -width/2, y: -height/2, width: width, height: height)
    }
}
