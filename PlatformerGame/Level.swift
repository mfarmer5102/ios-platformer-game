import SpriteKit

class Level {
    
    var tileSize: CGFloat = 32
    var levelWidth: Int = 100
    var levelHeight: Int = 20
    
    func createLevel1(in scene: SKScene) {
        createGround(in: scene)
        createPlatforms(in: scene)
        createStars(in: scene)
        createEnemies(in: scene)
        createBackground(in: scene)
        createFinishLine(in: scene)
    }
    
    func createGround(in scene: SKScene) {
        // Create ground tiles - much longer level
        let groundY: CGFloat = -scene.size.height/2 + tileSize/2
        
        for i in -100...200 {
            let groundTile = createGroundTile()
            groundTile.position = CGPoint(x: CGFloat(i) * tileSize, y: groundY)
            scene.addChild(groundTile)
        }
        
        // Create some underground tiles for depth
        for i in -100...200 {
            for j in 1...3 {
                let undergroundTile = createGroundTile()
                undergroundTile.color = .brown
                undergroundTile.position = CGPoint(x: CGFloat(i) * tileSize, y: groundY - CGFloat(j) * tileSize)
                scene.addChild(undergroundTile)
            }
        }
    }
    
    func createPlatforms(in scene: SKScene) {
        let groundY: CGFloat = -scene.size.height/2 + tileSize/2
        
        // Early platforms
        createPlatform(in: scene, startX: 5, endX: 8, y: groundY + 3 * tileSize)
        createPlatform(in: scene, startX: 12, endX: 15, y: groundY + 5 * tileSize)
        createPlatform(in: scene, startX: 20, endX: 22, y: groundY + 2 * tileSize)
        createPlatform(in: scene, startX: 25, endX: 28, y: groundY + 6 * tileSize)
        createPlatform(in: scene, startX: 35, endX: 37, y: groundY + 4 * tileSize)
        
        // Mid-level platforms
        createPlatform(in: scene, startX: 45, endX: 48, y: groundY + 3 * tileSize)
        createPlatform(in: scene, startX: 55, endX: 58, y: groundY + 5 * tileSize)
        createPlatform(in: scene, startX: 65, endX: 67, y: groundY + 2 * tileSize)
        createPlatform(in: scene, startX: 75, endX: 78, y: groundY + 6 * tileSize)
        createPlatform(in: scene, startX: 85, endX: 87, y: groundY + 4 * tileSize)
        
        // Later platforms
        createPlatform(in: scene, startX: 95, endX: 98, y: groundY + 3 * tileSize)
        createPlatform(in: scene, startX: 105, endX: 108, y: groundY + 5 * tileSize)
        createPlatform(in: scene, startX: 115, endX: 117, y: groundY + 2 * tileSize)
        createPlatform(in: scene, startX: 125, endX: 128, y: groundY + 6 * tileSize)
        createPlatform(in: scene, startX: 135, endX: 137, y: groundY + 4 * tileSize)
        
        // End area platforms
        createPlatform(in: scene, startX: 145, endX: 148, y: groundY + 3 * tileSize)
        createPlatform(in: scene, startX: 155, endX: 158, y: groundY + 5 * tileSize)
        createPlatform(in: scene, startX: 165, endX: 167, y: groundY + 2 * tileSize)
        createPlatform(in: scene, startX: 175, endX: 178, y: groundY + 6 * tileSize)
        createPlatform(in: scene, startX: 185, endX: 190, y: groundY + 4 * tileSize)
        
        // Moving platforms
        let movingPlatform1 = createPlatformTile()
        movingPlatform1.position = CGPoint(x: 30 * tileSize, y: groundY + 8 * tileSize)
        movingPlatform1.color = .purple
        scene.addChild(movingPlatform1)
        
        let movingPlatform2 = createPlatformTile()
        movingPlatform2.position = CGPoint(x: 70 * tileSize, y: groundY + 7 * tileSize)
        movingPlatform2.color = .purple
        scene.addChild(movingPlatform2)
        
        let movingPlatform3 = createPlatformTile()
        movingPlatform3.position = CGPoint(x: 110 * tileSize, y: groundY + 8 * tileSize)
        movingPlatform3.color = .purple
        scene.addChild(movingPlatform3)
        
        // Add movement to the platforms
        for (i, platform) in [movingPlatform1, movingPlatform2, movingPlatform3].enumerated() {
            let moveUp = SKAction.moveBy(x: 0, y: 3 * tileSize, duration: 2.0 + Double(i) * 0.5)
            let moveDown = SKAction.moveBy(x: 0, y: -3 * tileSize, duration: 2.0 + Double(i) * 0.5)
            let sequence = SKAction.sequence([moveUp, moveDown])
            let repeatAction = SKAction.repeatForever(sequence)
            platform.run(repeatAction)
        }
    }
    
    func createPlatform(in scene: SKScene, startX: Int, endX: Int, y: CGFloat) {
        for i in startX...endX {
            let platformTile = createPlatformTile()
            platformTile.position = CGPoint(x: CGFloat(i) * tileSize, y: y)
            scene.addChild(platformTile)
        }
    }
    
    func createStars(in scene: SKScene) {
        let groundY: CGFloat = -scene.size.height/2 + tileSize/2
        
        // Stars on ground throughout the level (increased by 50%)
        let starPositions = [3, 6, 9, 12, 16, 19, 23, 26, 29, 32, 35, 38, 41, 43, 46, 49, 52, 56, 59, 62, 65, 69, 72, 76, 79, 83, 86, 89, 92, 96, 99, 103, 106, 109, 112, 116, 119, 123, 126, 129, 132, 136, 139, 143, 146, 149, 152, 156, 159, 163, 166, 169, 172, 176, 179, 183]
        for x in starPositions {
            let star = createStar()
            star.position = CGPoint(x: CGFloat(x) * tileSize, y: groundY + 2 * tileSize)
            scene.addChild(star)
        }
        
        // Stars on platforms (increased by 50%)
        let platformStarPositions = [(6, 5), (9, 6), (13, 7), (16, 8), (26, 8), (29, 7), (33, 6), (46, 5), (49, 6), (56, 7), (59, 8), (63, 7), (76, 8), (79, 7), (83, 6), (96, 5), (99, 6), (106, 7), (109, 8), (113, 7), (126, 8), (129, 7), (133, 6), (146, 5), (149, 6), (156, 7), (159, 8), (163, 7), (176, 8), (179, 7)]
        for (x, height) in platformStarPositions {
            let star = createStar()
            star.position = CGPoint(x: CGFloat(x) * tileSize, y: groundY + CGFloat(height) * tileSize)
            scene.addChild(star)
        }
        
        // Special star trails (increased by 50%)
        for i in 0...8 {
            let star = createStar()
            star.position = CGPoint(x: CGFloat(40 + i * 2) * tileSize, y: groundY + CGFloat(3 + i) * tileSize)
            scene.addChild(star)
        }
        
        for i in 0...6 {
            let star = createStar()
            star.position = CGPoint(x: CGFloat(80 + i * 2) * tileSize, y: groundY + CGFloat(4 + i) * tileSize)
            scene.addChild(star)
        }
    }
    
    func createEnemies(in scene: SKScene) {
        let groundY: CGFloat = -scene.size.height/2 + tileSize/2
        
        // Ground enemies - evenly distributed every 4-6 tiles across the entire stage
        let enemyPositions = [8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176, 180, 184, 188, 192, 196]
        for x in enemyPositions {
            let enemy = Enemy()
            enemy.position = CGPoint(x: CGFloat(x) * tileSize, y: groundY + tileSize)
            scene.addChild(enemy)
        }
        
        // Platform enemies - evenly distributed on platforms throughout the stage
        let platformEnemyPositions = [(15, 6), (25, 7), (35, 8), (45, 6), (55, 7), (65, 8), (75, 6), (85, 7), (95, 8), (105, 6), (115, 7), (125, 8), (135, 6), (145, 7), (155, 8), (165, 6), (175, 7), (185, 8), (195, 6)]
        for (x, height) in platformEnemyPositions {
            let enemy = Enemy()
            enemy.position = CGPoint(x: CGFloat(x) * tileSize, y: groundY + CGFloat(height) * tileSize)
            scene.addChild(enemy)
        }
    }
    
    func createBackground(in scene: SKScene) {
        // Load the background image
        let bgTexture = SKTexture(imageNamed: "bg")
        
        // Check if the texture loaded properly by checking its size
        if bgTexture.size().width == 0 || bgTexture.size().height == 0 {
            print("Could not load bg image, falling back to solid color")
            // Fallback to solid color background
            let background = SKSpriteNode(color: .cyan, size: CGSize(width: 10000, height: scene.size.height))
            background.position = CGPoint(x: 2000, y: 0)
            background.zPosition = -100
            scene.addChild(background)
            return
        }
        
        // Calculate how many background images we need to cover the level
        let bgWidth = bgTexture.size().width
        let levelWidth: CGFloat = 10000 // Total level width
        
        // Scale background to fit the scene height while maintaining aspect ratio
        let bgHeight = bgTexture.size().height
        let sceneHeight = scene.size.height
        let scaleFactor = sceneHeight / bgHeight
        let scaledWidth = bgWidth * scaleFactor
        
        // Recalculate how many backgrounds we need with the new scaled width
        let numScaledBackgrounds = Int(ceil(levelWidth / scaledWidth)) + 2
        
        for i in 0..<numScaledBackgrounds {
            let background = SKSpriteNode(texture: bgTexture)
            // Scale to fit scene height while maintaining aspect ratio
            background.size = CGSize(width: scaledWidth, height: sceneHeight)
            
            // Position backgrounds side by side, starting from the left edge of the level
            let xPosition = CGFloat(i) * scaledWidth - 2000 // Start from left edge
            background.position = CGPoint(x: xPosition, y: 0) // Center vertically
            background.zPosition = -100
            
            scene.addChild(background)
        }
    }
    
    
    // MARK: - Tile Creation Methods
    
    func createGroundTile() -> SKSpriteNode {
        let tile = SKSpriteNode(color: .green, size: CGSize(width: tileSize, height: tileSize))
        
        // Add physics body
        tile.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        tile.physicsBody?.categoryBitMask = PhysicsCategory.ground
        tile.physicsBody?.isDynamic = false
        tile.physicsBody?.friction = 0.6
        
        return tile
    }
    
    func createPlatformTile() -> SKSpriteNode {
        let tile = SKSpriteNode(color: .orange, size: CGSize(width: tileSize, height: tileSize/2))
        
        // Add physics body
        tile.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        tile.physicsBody?.categoryBitMask = PhysicsCategory.ground
        tile.physicsBody?.isDynamic = false
        tile.physicsBody?.friction = 0.6
        
        return tile
    }
    
    func createStar() -> SKSpriteNode {
        // Create a star shape using a custom texture
        let starTexture = createStarTexture()
        let star = SKSpriteNode(texture: starTexture, size: CGSize(width: 20, height: 20))
        
        // Add physics body
        star.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        star.physicsBody?.categoryBitMask = PhysicsCategory.collectible
        star.physicsBody?.contactTestBitMask = PhysicsCategory.player
        star.physicsBody?.isDynamic = false
        
        // Add spinning animation
        let spin = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
        let repeatSpin = SKAction.repeatForever(spin)
        star.run(repeatSpin)
        
        // Add floating animation
        let float = SKAction.moveBy(x: 0, y: 10, duration: 1.0)
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 1.0)
        let floatSequence = SKAction.sequence([float, floatDown])
        let repeatFloat = SKAction.repeatForever(floatSequence)
        star.run(repeatFloat)
        
        return star
    }
    
    func createStarTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Set star color (golden yellow)
            cgContext.setFillColor(UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).cgColor)
            cgContext.setStrokeColor(UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor)
            cgContext.setLineWidth(1.0)
            
            // Create a 5-pointed star
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let outerRadius: CGFloat = 8
            let innerRadius: CGFloat = 3
            
            cgContext.move(to: CGPoint(x: center.x, y: center.y - outerRadius))
            
            for i in 0..<10 {
                let angle = CGFloat(i) * CGFloat.pi / 5 - CGFloat.pi / 2
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let x = center.x + radius * cos(angle)
                let y = center.y + radius * sin(angle)
                cgContext.addLine(to: CGPoint(x: x, y: y))
            }
            
            cgContext.closePath()
            cgContext.fillPath()
            cgContext.strokePath()
        }
        return SKTexture(image: image)
    }
    
    func createWall() -> SKSpriteNode {
        let wall = SKSpriteNode(color: .gray, size: CGSize(width: tileSize, height: tileSize * 3))
        
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.isDynamic = false
        
        return wall
    }
    
    // MARK: - Power-up Creation
    
    func createMushroom(at position: CGPoint, in scene: SKScene) {
        let mushroom = SKSpriteNode(color: .red, size: CGSize(width: 24, height: 24))
        mushroom.position = position
        
        mushroom.physicsBody = SKPhysicsBody(rectangleOf: mushroom.size)
        mushroom.physicsBody?.categoryBitMask = PhysicsCategory.collectible
        mushroom.physicsBody?.contactTestBitMask = PhysicsCategory.player
        mushroom.physicsBody?.collisionBitMask = PhysicsCategory.ground
        mushroom.physicsBody?.isDynamic = true
        
        // Add white spots to make it look more like a mushroom
        let spot1 = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 4))
        spot1.position = CGPoint(x: -6, y: 4)
        mushroom.addChild(spot1)
        
        let spot2 = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 4))
        spot2.position = CGPoint(x: 6, y: 2)
        mushroom.addChild(spot2)
        
        scene.addChild(mushroom)
        
        // Make it move
        mushroom.physicsBody?.velocity = CGVector(dx: 50, dy: 0)
    }
    
    func createFinishLine(in scene: SKScene) {
        let groundY: CGFloat = -scene.size.height/2 + tileSize/2
        let finishX: CGFloat = CGFloat(195) * tileSize // Near the end of the level
        
        // Create finish line flag pole
        let flagPole = SKSpriteNode(color: .brown, size: CGSize(width: 8, height: tileSize * 6))
        flagPole.position = CGPoint(x: finishX, y: groundY + tileSize * 3)
        flagPole.zPosition = 10
        scene.addChild(flagPole)
        
        // Create flag
        let flag = SKSpriteNode(color: .green, size: CGSize(width: tileSize, height: tileSize))
        flag.position = CGPoint(x: finishX + tileSize/2, y: groundY + tileSize * 5)
        flag.zPosition = 11
        scene.addChild(flag)
        
        // Add some visual flair - finish line text
        let finishLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        finishLabel.text = "FINISH"
        finishLabel.fontSize = 20
        finishLabel.fontColor = .white
        finishLabel.position = CGPoint(x: finishX, y: groundY + tileSize * 7)
        finishLabel.zPosition = 12
        scene.addChild(finishLabel)
    }
}
