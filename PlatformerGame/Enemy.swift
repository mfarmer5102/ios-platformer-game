import SpriteKit

class Enemy: SKSpriteNode {
    
    var moveSpeed: CGFloat = 50
    var direction: CGFloat = 1 // 1 for right, -1 for left
    var isAlive = true
    
    // Animation properties
    var bug1Texture: SKTexture!
    var bug2Texture: SKTexture!
    var walkTextures: [SKTexture] = []
    
    init() {
        // Load bug textures
        bug1Texture = SKTexture(imageNamed: "bug1")
        bug2Texture = SKTexture(imageNamed: "bug2")
        
        // Use bug1 as the default texture and make it slightly larger than before
        super.init(texture: bug1Texture, color: .clear, size: CGSize(width: 32, height: 32))
        
        setupAnimations()
        setupPhysics()
        setupMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimations() {
        // Set up walking animation textures
        walkTextures = [bug1Texture, bug2Texture]
    }
    
    func animateWalking() {
        if isAlive && action(forKey: "walking") == nil {
            let walkAnimation = SKAction.animate(with: walkTextures, timePerFrame: 0.3)
            let repeatAction = SKAction.repeatForever(walkAnimation)
            run(repeatAction, withKey: "walking")
        }
    }
    
    func stopWalkingAnimation() {
        removeAction(forKey: "walking")
        texture = bug1Texture // Reset to default texture
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.2
    }
    
    func setupMovement() {
        // Start moving
        physicsBody?.velocity = CGVector(dx: moveSpeed * direction, dy: 0)
        
        // Start walking animation
        animateWalking()
        
        // Set up patrol behavior
        startPatrolling()
    }
    
    func startPatrolling() {
        let patrol = SKAction.run {
            self.patrol()
        }
        let wait = SKAction.wait(forDuration: 0.1)
        let patrolSequence = SKAction.sequence([patrol, wait])
        let repeatPatrol = SKAction.repeatForever(patrolSequence)
        
        run(repeatPatrol, withKey: "patrol")
    }
    
    func patrol() {
        guard isAlive else { return }
        
        // Check for edges or walls
        let raycast = CGPoint(x: position.x + (direction * 30), y: position.y - 20)
        
        // Simple edge detection - if we're about to walk off a platform, turn around
        if let scene = scene {
            let groundCheck = scene.physicsWorld.body(at: raycast)
            if groundCheck?.categoryBitMask != PhysicsCategory.ground {
                changeDirection()
            }
        }
        
        // Keep moving in current direction
        physicsBody?.velocity.dx = moveSpeed * direction
    }
    
    func changeDirection() {
        direction *= -1
        xScale = direction // Flip sprite to face movement direction
    }
    
    func takeDamage() {
        guard isAlive else { return }
        
        isAlive = false
        
        // Stop movement and animation
        removeAction(forKey: "patrol")
        stopWalkingAnimation()
        physicsBody?.velocity = CGVector.zero
        
        // Death animation
        let squash = SKAction.scaleY(to: 0.5, duration: 0.1)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        let deathSequence = SKAction.sequence([squash, fade, remove])
        run(deathSequence)
        
        // Add score to game
        if let gameScene = scene as? GameScene {
            gameScene.addScore(100)
        }
    }
    
    override func removeFromParent() {
        // Clean up actions
        removeAllActions()
        super.removeFromParent()
    }
}

// MARK: - Specific Enemy Types

class Goomba: Enemy {
    
    override init() {
        super.init()
        moveSpeed = 30
        // The sprite textures are already set up in the parent class
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KoopaTroopa: Enemy {
    
    var isInShell = false
    var shellSpeed: CGFloat = 200
    
    override init() {
        super.init()
        moveSpeed = 40
        // The sprite textures are already set up in the parent class
        // For now, KoopaTroopa uses the same bug sprites as Goomba
        // In the future, you could create separate koopa sprites
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func takeDamage() {
        if !isInShell {
            // First hit - go into shell
            enterShell()
        } else {
            // Second hit - destroy
            super.takeDamage()
        }
    }
    
    func enterShell() {
        isInShell = true
        
        // Stop normal movement and animation
        removeAction(forKey: "patrol")
        stopWalkingAnimation()
        physicsBody?.velocity = CGVector.zero
        
        // Change physics properties
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        
        // Wait for player to kick the shell
        let waitForKick = SKAction.wait(forDuration: 0.5)
        let enableKick = SKAction.run {
            // Shell can now be kicked by player
        }
        run(SKAction.sequence([waitForKick, enableKick]))
    }
    
    func kickShell(direction: CGFloat) {
        guard isInShell else { return }
        
        // Launch shell at high speed
        physicsBody?.velocity = CGVector(dx: shellSpeed * direction, dy: 0)
        
        // Shell becomes dangerous to other enemies
        physicsBody?.categoryBitMask = PhysicsCategory.collectible // Temporarily change category
        
        // Auto-destroy after some time
        let destroyAfterTime = SKAction.sequence([
            SKAction.wait(forDuration: 10.0),
            SKAction.run { self.takeDamage() }
        ])
        run(destroyAfterTime, withKey: "shellDestroy")
    }
}
