import SpriteKit
import GameplayKit

// Physics categories for collision detection
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1        // 1
    static let ground: UInt32 = 0b10       // 2
    static let enemy: UInt32 = 0b100       // 4
    static let collectible: UInt32 = 0b1000 // 8
    static let wall: UInt32 = 0b10000      // 16
}

class GameScene: SKScene {
    
    // Game objects
    var player: Player!
    var gameCamera: GameCamera!
    var level: Level!
    
    // Game state
    var score = 0
    var lives = 3
    var isGamePaused = false
    
    // Input state for simultaneous button presses
    var isLeftPressed = false
    var isRightPressed = false
    var isJumpPressed = false
    
    // UI elements
    var scoreLabel: SKLabelNode!
    var heartSprites: [SKSpriteNode] = []
    var timerLabel: SKLabelNode!
    
    // Timer system
    var gameTimer: TimeInterval = 300.0 // 5 minutes
    var lastUpdateTime: TimeInterval = 0
    
    // Input handling
    var leftButton: SKSpriteNode!
    var rightButton: SKSpriteNode!
    var jumpButton: SKSpriteNode!
    var pauseButton: SKSpriteNode!
    
    // Pause menu
    var pauseMenu: SKNode!
    var pauseBackground: SKSpriteNode!
    var resumeButton: SKSpriteNode!
    var restartButton: SKSpriteNode!
    
    // Game over elements
    var gameOverLabel: SKLabelNode?
    var gameOverRestartLabel: SKLabelNode?
    
    // Win condition elements
    var youWinLabel: SKLabelNode?
    var continueButton: SKSpriteNode?
    var isGameWon = false
    var currentStage = 1
    
    // Stage boundaries
    var stageStartX: CGFloat = -400
    var stageEndX: CGFloat = 6400  // Around tile 200
    
    override func didMove(to view: SKView) {
        NSLog("GameScene: didMove called")
        setupPhysics()
        setupLevel()
        setupPlayer()
        setupCamera()
        setupUI()
        setupControls()
        setupPauseMenu()
        setupWinCondition()
        NSLog("GameScene: Setup complete, player position: \(player.position)")
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }
    
    func setupUI() {
        // Score label with retro font (directly above hearts, slightly adjusted)
        scoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        scoreLabel.text = "000000"
        scoreLabel.fontSize = 16
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: -size.width/2 + 70, y: size.height/2 - 40) // Just above the top of the hearts
        scoreLabel.zPosition = 100
        
        // Create heart sprites for lives
        createHeartSprites()
        
        // Timer label (top right, moved down)
        timerLabel = SKLabelNode(fontNamed: "Courier-Bold")
        timerLabel.text = "05:00"
        timerLabel.fontSize = 24
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: size.width/2 - 80, y: size.height/2 - 60)
        timerLabel.zPosition = 100
        
        // Add UI elements to camera so they stay in place
        gameCamera.addChild(scoreLabel)
        gameCamera.addChild(timerLabel)
        for heart in heartSprites {
            gameCamera.addChild(heart)
        }
    }
    
    func createHeartSprites() {
        heartSprites.removeAll()
        
        for i in 0..<3 {
            let heart = createHeartSprite()
            heart.position = CGPoint(x: -size.width/2 + 40 + CGFloat(i * 32), y: size.height/2 - 60)
            heart.zPosition = 100
            heartSprites.append(heart)
        }
    }
    
    func createHeartSprite() -> SKSpriteNode {
        let heartTexture = createHeartTexture()
        let heart = SKSpriteNode(texture: heartTexture, size: CGSize(width: 28, height: 25))
        return heart
    }
    
    func createHeartTexture() -> SKTexture {
        let size = CGSize(width: 28, height: 25)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Set heart color (red)
            cgContext.setFillColor(UIColor.red.cgColor)
            cgContext.setStrokeColor(UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0).cgColor)
            cgContext.setLineWidth(1.0)
            
            // Create heart shape
            let centerX = size.width / 2
            let centerY = size.height / 2
            
            // Heart shape using two circles and a triangle
            cgContext.move(to: CGPoint(x: centerX, y: centerY + 6))
            
            // Left curve
            cgContext.addCurve(to: CGPoint(x: centerX - 6, y: centerY - 2),
                             control1: CGPoint(x: centerX - 2, y: centerY + 4),
                             control2: CGPoint(x: centerX - 6, y: centerY + 2))
            
            // Top left curve
            cgContext.addCurve(to: CGPoint(x: centerX, y: centerY - 6),
                             control1: CGPoint(x: centerX - 6, y: centerY - 6),
                             control2: CGPoint(x: centerX - 3, y: centerY - 6))
            
            // Top right curve
            cgContext.addCurve(to: CGPoint(x: centerX + 6, y: centerY - 2),
                             control1: CGPoint(x: centerX + 3, y: centerY - 6),
                             control2: CGPoint(x: centerX + 6, y: centerY - 6))
            
            // Right curve
            cgContext.addCurve(to: CGPoint(x: centerX, y: centerY + 6),
                             control1: CGPoint(x: centerX + 6, y: centerY + 2),
                             control2: CGPoint(x: centerX + 2, y: centerY + 4))
            
            cgContext.closePath()
            cgContext.fillPath()
            cgContext.strokePath()
        }
        return SKTexture(image: image)
    }
    
    func addButtonOutline(to button: SKSpriteNode) {
        // Create a black outline border
        let outline = SKShapeNode(rect: CGRect(x: -button.size.width/2, y: -button.size.height/2, width: button.size.width, height: button.size.height))
        outline.strokeColor = .black
        outline.lineWidth = 1.0
        outline.fillColor = .clear
        outline.zPosition = 1
        button.addChild(outline)
    }
    
    func isPointInButton(_ point: CGPoint, button: SKSpriteNode) -> Bool {
        // Convert button position to camera space and check if point is within button bounds
        let buttonFrame = CGRect(
            x: button.position.x - button.size.width/2,
            y: button.position.y - button.size.height/2,
            width: button.size.width,
            height: button.size.height
        )
        let isInside = buttonFrame.contains(point)
        print("Checking button \(button.name ?? "unknown"): point \(point) in frame \(buttonFrame) = \(isInside)")
        return isInside
    }
    
    func setupControls() {
        // Calculate button dimensions - each button takes 25% of screen width
        let buttonWidth = size.width * 0.25
        let buttonHeight: CGFloat = 100
        
        // Left button (25% width)
        leftButton = SKSpriteNode(color: .blue, size: CGSize(width: buttonWidth, height: buttonHeight))
        leftButton.position = CGPoint(x: -size.width/2 + buttonWidth/2, y: -size.height/2 + 80)
        leftButton.alpha = 1.0  // Make fully visible
        leftButton.zPosition = 100
        leftButton.name = "leftButton"
        leftButton.isUserInteractionEnabled = true
        addButtonOutline(to: leftButton)
        
        // Right button (25% width)
        rightButton = SKSpriteNode(color: .blue, size: CGSize(width: buttonWidth, height: buttonHeight))
        rightButton.position = CGPoint(x: -size.width/2 + buttonWidth * 1.5, y: -size.height/2 + 80)
        rightButton.alpha = 1.0  // Make fully visible
        rightButton.zPosition = 100
        rightButton.name = "rightButton"
        rightButton.isUserInteractionEnabled = true
        addButtonOutline(to: rightButton)
        
        // Pause button (25% width)
        pauseButton = SKSpriteNode(color: .gray, size: CGSize(width: buttonWidth, height: buttonHeight))
        pauseButton.position = CGPoint(x: -size.width/2 + buttonWidth * 2.5, y: -size.height/2 + 80)
        pauseButton.alpha = 1.0  // Make fully visible
        pauseButton.zPosition = 100
        pauseButton.name = "pauseButton"
        pauseButton.isUserInteractionEnabled = true
        addButtonOutline(to: pauseButton)
        
        // Jump button (25% width)
        jumpButton = SKSpriteNode(color: .red, size: CGSize(width: buttonWidth, height: buttonHeight))
        jumpButton.position = CGPoint(x: -size.width/2 + buttonWidth * 3.5, y: -size.height/2 + 80)
        jumpButton.alpha = 1.0  // Make fully visible
        jumpButton.zPosition = 100
        jumpButton.name = "jumpButton"
        jumpButton.isUserInteractionEnabled = true
        addButtonOutline(to: jumpButton)
        
        // Add pause symbol
        let pauseLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        pauseLabel.text = "START"
        pauseLabel.fontSize = 16
        pauseLabel.fontColor = .white
        pauseLabel.position = CGPoint.zero
        pauseButton.addChild(pauseLabel)
        
        // Add labels to other buttons for debugging
        let leftLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        leftLabel.text = "LEFT"
        leftLabel.fontSize = 16
        leftLabel.fontColor = .white
        leftLabel.position = CGPoint.zero
        leftButton.addChild(leftLabel)
        
        let rightLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        rightLabel.text = "RIGHT"
        rightLabel.fontSize = 16
        rightLabel.fontColor = .white
        rightLabel.position = CGPoint.zero
        rightButton.addChild(rightLabel)
        
        let jumpLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        jumpLabel.text = "JUMP"
        jumpLabel.fontSize = 16
        jumpLabel.fontColor = .white
        jumpLabel.position = CGPoint.zero
        jumpButton.addChild(jumpLabel)
        
        // Add control buttons to camera so they stay in place relative to screen
        gameCamera.addChild(leftButton)
        gameCamera.addChild(rightButton)
        gameCamera.addChild(pauseButton)
        gameCamera.addChild(jumpButton)
        
        // Debug: Print button positions
        print("Button positions:")
        print("Left button: \(leftButton.position)")
        print("Right button: \(rightButton.position)")
        print("Pause button: \(pauseButton.position)")
        print("Jump button: \(jumpButton.position)")
        print("Scene size: \(size)")
        print("Camera position: \(gameCamera.position)")
    }
    
    func setupLevel() {
        level = Level()
        level.createLevel1(in: self)
    }
    
    func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: -400, y: 100)
        addChild(player)
    }
    
    func setupCamera() {
        gameCamera = GameCamera()
        camera = gameCamera
        addChild(gameCamera)
        gameCamera.follow(player)
    }
    
    func setupPauseMenu() {
        // Create pause menu container
        pauseMenu = SKNode()
        pauseMenu.zPosition = 200
        pauseMenu.isHidden = true
        
        // Semi-transparent background
        pauseBackground = SKSpriteNode(color: .black, size: CGSize(width: size.width, height: size.height))
        pauseBackground.alpha = 0.7
        pauseBackground.position = CGPoint.zero
        pauseMenu.addChild(pauseBackground)
        
        // Pause title
        let pauseTitle = SKLabelNode(fontNamed: "Arial-BoldMT")
        pauseTitle.text = "PAUSED"
        pauseTitle.fontSize = 48
        pauseTitle.fontColor = .white
        pauseTitle.position = CGPoint(x: 0, y: 100)
        pauseMenu.addChild(pauseTitle)
        
        // Resume button
        resumeButton = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 60))
        resumeButton.position = CGPoint(x: 0, y: 20)
        resumeButton.name = "resumeButton"
        pauseMenu.addChild(resumeButton)
        
        let resumeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        resumeLabel.text = "RESUME"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = .white
        resumeLabel.position = CGPoint.zero
        resumeButton.addChild(resumeLabel)
        
        // Restart button
        restartButton = SKSpriteNode(color: .orange, size: CGSize(width: 200, height: 60))
        restartButton.position = CGPoint(x: 0, y: -60)
        restartButton.name = "restartButton"
        pauseMenu.addChild(restartButton)
        
        let restartLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint.zero
        restartButton.addChild(restartLabel)
        
        // Add to camera so it follows
        gameCamera.addChild(pauseMenu)
    }
    
    func setupWinCondition() {
        // Create win message container (initially hidden)
        youWinLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        youWinLabel!.text = "YOU WIN!"
        youWinLabel!.fontSize = 48
        youWinLabel!.fontColor = .yellow
        youWinLabel!.position = CGPoint(x: 0, y: 50)
        youWinLabel!.zPosition = 200
        youWinLabel!.isHidden = true
        gameCamera.addChild(youWinLabel!)
        
        // Create continue button (initially hidden)
        continueButton = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 60))
        continueButton!.position = CGPoint(x: 0, y: -20)
        continueButton!.name = "continueButton"
        continueButton!.zPosition = 200
        continueButton!.isHidden = true
        
        let continueLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        continueLabel.text = "CONTINUE"
        continueLabel.fontSize = 24
        continueLabel.fontColor = .white
        continueLabel.position = CGPoint.zero
        continueButton!.addChild(continueLabel)
        
        gameCamera.addChild(continueButton!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let cameraLocation = touch.location(in: gameCamera)
            
            print("Touch detected at location: \(location), camera location: \(cameraLocation)")
            
            // Handle pause menu touches
            if !pauseMenu.isHidden {
                if resumeButton.contains(location) {
                    resumeGame()
                } else if restartButton.contains(location) {
                    restartGame()
                }
                return
            }
            
            // Handle game over screen touches
            if gameOverLabel != nil {
                restartGame()
                return
            }
            
            // Handle win screen touches
            if isGameWon && continueButton != nil && continueButton!.contains(location) {
                continueToNextStage()
                return
            }
            
            // Check if touch is on control buttons - allow simultaneous presses
            // Convert screen touch to camera coordinates
            let screenTouch = touch.location(in: self)
            let cameraTouch = CGPoint(x: screenTouch.x - gameCamera.position.x, y: screenTouch.y - gameCamera.position.y)
            
            if pauseButton.contains(cameraTouch) {
                print("Pause button pressed!")
                pauseGame()
            }
            
            if leftButton.contains(cameraTouch) {
                print("Left button pressed at \(cameraTouch)")
                isLeftPressed = true
                updatePlayerMovement()
            }
            
            if rightButton.contains(cameraTouch) {
                print("Right button pressed at \(cameraTouch)")
                isRightPressed = true
                updatePlayerMovement()
            }
            
            if jumpButton.contains(cameraTouch) {
                print("Jump button pressed at \(cameraTouch)")
                isJumpPressed = true
                player.jump()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Handle button releases for simultaneous input
            // Convert screen touch to camera coordinates
            let screenTouch = touch.location(in: self)
            let cameraTouch = CGPoint(x: screenTouch.x - gameCamera.position.x, y: screenTouch.y - gameCamera.position.y)
            
            if leftButton.contains(cameraTouch) {
                print("Left button released at \(cameraTouch)")
                isLeftPressed = false
                updatePlayerMovement()
            }
            
            if rightButton.contains(cameraTouch) {
                print("Right button released at \(cameraTouch)")
                isRightPressed = false
                updatePlayerMovement()
            }
            
            if jumpButton.contains(cameraTouch) {
                print("Jump button released")
                isJumpPressed = false
            }
        }
    }
    
    func updatePlayerMovement() {
        NSLog("Movement state - Left: \(isLeftPressed), Right: \(isRightPressed)")
        
        // TEMPORARY: Auto-walk right for testing
        NSLog("Auto-walking right")
        player.moveRight()
        
        // Original movement logic (commented out for now)
        /*
        if isLeftPressed && !isRightPressed {
            print("Moving left")
            player.moveLeft()
        } else if isRightPressed && !isLeftPressed {
            print("Moving right")
            player.moveRight()
        } else {
            if isLeftPressed && isRightPressed {
                print("Both buttons pressed - stopping")
            } else {
                print("No buttons pressed - stopping")
            }
            player.stopMoving()
        }
        */
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !isGamePaused && !isGameWon {
            NSLog("GameScene: update called, calling player.update()")
            updatePlayerMovement()
            player.update()
            gameCamera.update()
            
            // Update timer
            if lastUpdateTime == 0 {
                lastUpdateTime = currentTime
            }
            let deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            gameTimer -= deltaTime
            updateTimerDisplay()
            
            // Check if timer reached 0
            if gameTimer <= 0 {
                gameTimer = 0
                gameOver()
                return
            }
            
            // Enforce left boundary - don't let player go left of starting point
            if player.position.x < stageStartX {
                player.position.x = stageStartX
                player.physicsBody?.velocity.dx = 0
            }
            
            // Check win condition - player reached end of stage
            if player.position.x >= stageEndX && !isGameWon {
                playerWon()
            }
            
            // Debug: Print player position occasionally
            if Int(currentTime) % 2 == 0 && Int(currentTime * 10) % 10 == 0 {
                print("Player position: \(player.position), Camera position: \(gameCamera.position)")
                print("Movement state: Left=\(isLeftPressed), Right=\(isRightPressed), Jump=\(isJumpPressed)")
                
                // Safety check: if player velocity is 0 but buttons are pressed, reset movement
                if let velocity = player.physicsBody?.velocity {
                    if abs(velocity.dx) < 10 && (isLeftPressed || isRightPressed) {
                        print("WARNING: Player not moving despite button press - resetting movement")
                        updatePlayerMovement()
                    }
                }
            }
            
            // Check if player fell off the level
            if player.position.y < -500 {
                playerDied()
            }
        }
    }
    
    func addScore(_ points: Int) {
        score += points
        // Format score with leading zeros for retro look
        scoreLabel.text = String(format: "%06d", score)
    }
    
    func updateTimerDisplay() {
        let minutes = Int(gameTimer) / 60
        let seconds = Int(gameTimer) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func playerTookDamage() {
        lives -= 1
        updateHeartDisplay()
        
        if lives <= 0 {
            gameOver()
        }
        // Don't respawn immediately - let the player continue with invincibility frames
    }
    
    func playerDied() {
        lives -= 1
        updateHeartDisplay()
        
        if lives <= 0 {
            gameOver()
        } else {
            respawnPlayer()
        }
    }
    
    func updateHeartDisplay() {
        for (index, heart) in heartSprites.enumerated() {
            if index < lives {
                heart.alpha = 1.0 // Show heart
            } else {
                heart.alpha = 0.3 // Dim heart
            }
        }
    }
    
    func respawnPlayer() {
        player.position = CGPoint(x: -400, y: 100)
        player.physicsBody?.velocity = CGVector.zero
    }
    
    func killEnemy(_ enemy: Enemy) {
        // Create pop animation
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        let popAnimation = SKAction.group([
            SKAction.sequence([scaleUp, scaleDown]),
            fadeOut
        ])
        
        let killSequence = SKAction.sequence([popAnimation, remove])
        enemy.run(killSequence)
    }
    
    func gameOver() {
        isGamePaused = true
        physicsWorld.speed = 0
        
        // Create game over label and add to camera so it's always visible
        gameOverLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        gameOverLabel!.text = "GAME OVER"
        gameOverLabel!.fontSize = 48
        gameOverLabel!.fontColor = .red
        gameOverLabel!.position = CGPoint(x: 0, y: 50)
        gameOverLabel!.zPosition = 200
        gameCamera.addChild(gameOverLabel!)
        
        // Add restart functionality here
        gameOverRestartLabel = SKLabelNode(fontNamed: "Arial")
        gameOverRestartLabel!.text = "Tap to restart"
        gameOverRestartLabel!.fontSize = 24
        gameOverRestartLabel!.fontColor = .white
        gameOverRestartLabel!.position = CGPoint(x: 0, y: -20)
        gameOverRestartLabel!.zPosition = 200
        gameOverRestartLabel!.name = "restart"
        gameCamera.addChild(gameOverRestartLabel!)
    }
    
    func pauseGame() {
        isGamePaused = true
        pauseMenu.isHidden = false
        physicsWorld.speed = 0
        print("Game paused")
    }
    
    func resumeGame() {
        isGamePaused = false
        pauseMenu.isHidden = true
        physicsWorld.speed = 1
        print("Game resumed")
    }
    
    func restartGame() {
        // Clear game over elements if they exist
        gameOverLabel?.removeFromParent()
        gameOverLabel = nil
        gameOverRestartLabel?.removeFromParent()
        gameOverRestartLabel = nil
        
        // Clear win elements if they exist
        youWinLabel?.isHidden = true
        continueButton?.isHidden = true
        isGameWon = false
        
        // Reset game state
        score = 0
        lives = 3
        currentStage = 1
        gameTimer = 300.0 // Reset timer to 5 minutes
        lastUpdateTime = 0
        scoreLabel.text = "000000"
        updateTimerDisplay()
        updateHeartDisplay()
        
        // Reset input state
        isLeftPressed = false
        isRightPressed = false
        isJumpPressed = false
        
        // Reset player position
        player.position = CGPoint(x: stageStartX, y: 100)
        player.physicsBody?.velocity = CGVector.zero
        
        // Resume game
        resumeGame()
        print("Game restarted")
    }
    
    func playerWon() {
        isGameWon = true
        physicsWorld.speed = 0
        
        // Show win message
        youWinLabel?.isHidden = false
        continueButton?.isHidden = false
        
        print("Player won stage \(currentStage)!")
    }
    
    func continueToNextStage() {
        currentStage += 1
        isGameWon = false
        
        // Hide win elements
        youWinLabel?.isHidden = true
        continueButton?.isHidden = true
        
        // Reset player position to start of new stage
        player.position = CGPoint(x: stageStartX, y: 100)
        player.physicsBody?.velocity = CGVector.zero
        
        // Reset input state
        isLeftPressed = false
        isRightPressed = false
        isJumpPressed = false
        
        // Resume physics
        physicsWorld.speed = 1
        
        print("Starting stage \(currentStage)")
    }
}

// MARK: - Physics Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case PhysicsCategory.player | PhysicsCategory.collectible:
            handlePlayerCollectibleContact(contact)
        case PhysicsCategory.player | PhysicsCategory.enemy:
            handlePlayerEnemyContact(contact)
        case PhysicsCategory.player | PhysicsCategory.ground:
            handlePlayerGroundContact(contact)
        default:
            break
        }
    }
    
    func handlePlayerCollectibleContact(_ contact: SKPhysicsContact) {
        let collectible = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? contact.bodyA.node : contact.bodyB.node
        
        if let star = collectible {
            // Create collection animation
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
            let scaleDown = SKAction.scale(to: 0.0, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.removeFromParent()
            
            let collectAnimation = SKAction.group([
                SKAction.sequence([scaleUp, scaleDown]),
                fadeOut
            ])
            
            let collectSequence = SKAction.sequence([collectAnimation, remove])
            star.run(collectSequence)
            
            addScore(100)
            
            // Play star collection sound effect here
        }
    }
    
    func handlePlayerEnemyContact(_ contact: SKPhysicsContact) {
        let enemy = contact.bodyA.categoryBitMask == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node
        
        if let enemyNode = enemy as? Enemy {
            // Check if player is jumping on enemy
            if player.position.y > enemyNode.position.y + 20 {
                // Player jumped on enemy - kill enemy with pop animation
                killEnemy(enemyNode)
                addScore(200)
                player.physicsBody?.velocity.dy = 300 // Bounce effect
            } else {
                // Player hit enemy from side - take damage
                player.takeDamage()
            }
        }
    }
    
    func handlePlayerGroundContact(_ contact: SKPhysicsContact) {
        player.isOnGround = true
    }
}
