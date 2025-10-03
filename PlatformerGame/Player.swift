import SpriteKit
import AVFoundation

class Player: SKSpriteNode {
    
    // Movement properties
    var moveSpeed: CGFloat = 200
    var jumpForce: CGFloat = 700
    var isOnGround = false
    var isMovingLeft = false
    var isMovingRight = false
    
    // Animation properties
    var idleTextures: [SKTexture] = []
    var runTextures: [SKTexture] = []
    var jumpTexture: SKTexture!
    
    
    // Walking sprite textures
    var walk1Texture: SKTexture!
    var walk2Texture: SKTexture!
    
    // Power-up states
    var isSuper = false
    var hasFirePower = false
    
    // Invincibility system
    var isInvincible = false
    var invincibilityDuration: TimeInterval = 3.0
    
    // Audio properties
    var hopSoundPlayer: AVAudioPlayer?
    var ouchSoundPlayer: AVAudioPlayer?
    
    init() {
        // Load walking textures
        walk1Texture = SKTexture(imageNamed: "walk1")
        walk2Texture = SKTexture(imageNamed: "walk2")
        
        // Use walk1 as the default texture, make it 1.5x larger and slightly taller
        super.init(texture: walk1Texture, color: .clear, size: CGSize(width: 48, height: 56))
        
        setupPhysics()
        setupAnimations()
        setupAudio()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.enemy | PhysicsCategory.collectible
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.0
    }
    
    func setupAnimations() {
        // Use the walking sprites for animations
        idleTextures = [walk1Texture]
        runTextures = [walk1Texture, walk2Texture]
        jumpTexture = walk1Texture // Use walk1 for jumping too
    }
    
    func setupAudio() {
        // Set up audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Load hop sound
        if let hopSoundURL = Bundle.main.url(forResource: "hopsound", withExtension: "m4a") {
            do {
                hopSoundPlayer = try AVAudioPlayer(contentsOf: hopSoundURL)
                hopSoundPlayer?.prepareToPlay()
                print("Loaded hop sound successfully")
            } catch {
                print("Error loading hop sound: \(error)")
            }
        } else {
            print("Could not find hopsound.m4a")
        }
        
        // Load ouch sound
        if let ouchSoundURL = Bundle.main.url(forResource: "ouch", withExtension: "m4a") {
            do {
                ouchSoundPlayer = try AVAudioPlayer(contentsOf: ouchSoundURL)
                ouchSoundPlayer?.prepareToPlay()
                print("Loaded ouch sound successfully")
            } catch {
                print("Error loading ouch sound: \(error)")
            }
        } else {
            print("Could not find ouch.m4a")
        }
    }
    
    func createColorTexture(_ color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 48, height: 56))
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 48, height: 56)))
        }
        return SKTexture(image: image)
    }
    
    func moveLeft() {
        isMovingLeft = true
        isMovingRight = false
        xScale = -abs(xScale) // Flip sprite to face left
    }
    
    func moveRight() {
        print("Player moveRight() called - setting isMovingRight = true")
        isMovingRight = true
        isMovingLeft = false
        xScale = abs(xScale) // Face right
    }
    
    func stopMoving() {
        isMovingLeft = false
        isMovingRight = false
    }
    
    func jump() {
        if isOnGround {
            print("Player jumping - was on ground")
            physicsBody?.velocity.dy = jumpForce
            isOnGround = false
            
            // Play jump animation
            texture = jumpTexture
            
            // Play jump sound effect
            print("Attempting to play hop sound...")
            hopSoundPlayer?.stop()
            hopSoundPlayer?.currentTime = 0
            hopSoundPlayer?.play()
            print("Hop sound played")
        } else {
            print("Player jump attempted but not on ground")
        }
    }
    
    func update() {
        // Handle horizontal movement
        if isMovingLeft {
            print("Player update: Moving left, setting velocity to \(-moveSpeed)")
            physicsBody?.velocity.dx = -moveSpeed
            animateRunning()
        } else if isMovingRight {
            print("Player update: Moving right, setting velocity to \(moveSpeed)")
            physicsBody?.velocity.dx = moveSpeed
            animateRunning()
        } else {
            print("Player update: Not moving, applying friction")
            // Apply friction when not moving
            if let velocity = physicsBody?.velocity {
                physicsBody?.velocity.dx = velocity.dx * 0.8
            }
            // Stop running animation when not moving horizontally
            removeAction(forKey: "running")
            animateIdle()
        }
        
        // Limit horizontal velocity
        if let velocity = physicsBody?.velocity {
            if abs(velocity.dx) > moveSpeed {
                physicsBody?.velocity.dx = velocity.dx > 0 ? moveSpeed : -moveSpeed
            }
        }
        
        // Check if still on ground (simple check)
        if let velocity = physicsBody?.velocity, velocity.dy < -10 {
            isOnGround = false
        }
    }
    
    func animateIdle() {
        if !isOnGround {
            texture = jumpTexture
        } else if action(forKey: "running") == nil {
            texture = idleTextures[0]
        }
    }
    
    func animateRunning() {
        // Animate when moving horizontally (on ground or in air)
        if (isMovingLeft || isMovingRight) && action(forKey: "running") == nil {
            let runAnimation = SKAction.animate(with: runTextures, timePerFrame: 0.2)
            let repeatAction = SKAction.repeatForever(runAnimation)
            run(repeatAction, withKey: "running")
        } else if !isMovingLeft && !isMovingRight {
            // Stop animation only when not moving horizontally
            removeAction(forKey: "running")
        }
    }
    
    func powerUp() {
        if !isSuper {
            // Transform to Super Mario equivalent
            isSuper = true
            size = CGSize(width: 48, height: 72)
            
            // Update physics body
            physicsBody = SKPhysicsBody(rectangleOf: size)
            setupPhysics()
            
            // Change color to indicate power-up
            color = .blue
            
            // Play power-up sound and animation here
        }
    }
    
    func takeDamage() {
        // Don't take damage if already invincible
        guard !isInvincible else { return }
        
        // Play ouch sound when taking damage
        print("Attempting to play ouch sound...")
        ouchSoundPlayer?.stop()
        ouchSoundPlayer?.currentTime = 0
        ouchSoundPlayer?.play()
        print("Ouch sound played")
        
        if isSuper {
            // Revert to small Mario
            isSuper = false
            hasFirePower = false
            size = CGSize(width: 48, height: 56)
            color = .clear // Reset to clear since we're using sprites now
            
            // Update physics body
            physicsBody = SKPhysicsBody(rectangleOf: size)
            setupPhysics()
            
            // Add invincibility frames
            startInvincibility()
        } else {
            // Player takes damage but gets invincibility frames
            if let gameScene = scene as? GameScene {
                gameScene.playerTookDamage()
            }
            startInvincibility()
        }
    }
    
    func startInvincibility() {
        isInvincible = true
        
        // Create flashing animation
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let flashRepeat = SKAction.repeat(flash, count: 15) // 3 seconds total
        
        // Disable enemy collision temporarily
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.collectible
        
        // End invincibility after duration
        let endInvincibility = SKAction.run {
            self.isInvincible = false
            self.alpha = 1.0
            self.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.enemy | PhysicsCategory.collectible
        }
        
        // Run the sequence
        run(SKAction.sequence([flashRepeat, endInvincibility]))
    }
}
