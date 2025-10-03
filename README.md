# Platformer Game - Super Mario World Inspired

A side-scrolling platformer game for iOS built with SpriteKit, inspired by Super Mario World.

## Features

### ✅ Implemented
- **Player Character**: Red square character with movement, jumping, and basic animations
- **Physics System**: Gravity, collision detection, and realistic movement
- **Level System**: Tile-based level with platforms, ground, and obstacles
- **Side-Scrolling Camera**: Smooth camera that follows the player with dead zones
- **Enemies**: Purple enemies that patrol platforms and can be defeated by jumping on them
- **Collectibles**: Yellow spinning coins that add to your score
- **Power-ups**: Mushroom power-ups that make the player larger and stronger
- **Game UI**: Score display, lives counter, and touch controls
- **Touch Controls**: Left/Right movement buttons and jump button

### 🎮 Gameplay
- Move left and right using the blue control buttons
- Jump using the red jump button
- Collect yellow coins for points (100 points each)
- Jump on purple enemies to defeat them (200 points each)
- Avoid touching enemies from the side or you'll lose a life
- Collect red mushrooms to power up (become larger and stronger)
- Don't fall off the level or you'll lose a life

### 🏗️ Game Architecture

#### Core Classes
- **GameScene**: Main game scene handling physics, UI, and game logic
- **Player**: Player character with movement, animations, and power-up states
- **Level**: Level generation system creating platforms, enemies, and collectibles
- **Enemy**: Base enemy class with AI patrol behavior
- **GameCamera**: Side-scrolling camera with smooth following and effects

#### Physics Categories
- Player: Collision with ground, enemies, and collectibles
- Ground: Static platforms and terrain
- Enemy: Moving enemies with patrol AI
- Collectible: Coins and power-ups
- Wall: Invisible barriers for enemy AI

## Setup Instructions

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- iPhone or iPad

### Installation
1. Open `PlatformerGame.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press `Cmd + R` to build and run

### Controls
- **Left Button** (Blue): Move player left
- **Right Button** (Blue): Move player right  
- **Jump Button** (Red): Make player jump
- Touch and hold movement buttons for continuous movement
- Release movement buttons to stop

## Game Features Detail

### Player Mechanics
- **Movement**: Smooth horizontal movement with acceleration and friction
- **Jumping**: Variable height jumping based on button press duration
- **Power States**: 
  - Small Mario: Default state, dies in one hit
  - Super Mario: Larger size, can take one hit before reverting
- **Animations**: Different textures for idle, running, and jumping states

### Level Design
- **Ground Tiles**: Green tiles forming the base terrain
- **Platforms**: Orange floating platforms at various heights
- **Moving Platforms**: Purple platforms that move up and down
- **Background**: Cyan sky with white clouds and green hills

### Enemy AI
- **Patrol Behavior**: Enemies walk back and forth on platforms
- **Edge Detection**: Enemies turn around at platform edges
- **Collision Response**: Enemies can be defeated by jumping on them
- **Multiple Types**: Basic enemies and Koopa Troopa variants

### Camera System
- **Dead Zone**: Camera only moves when player exits a central area
- **Smooth Following**: Interpolated camera movement for smooth scrolling
- **Bounds**: Camera is constrained to prevent showing empty areas
- **Effects**: Screen shake and zoom capabilities for game events

## Future Enhancements

### 🔊 Audio (Planned)
- Jump sound effects
- Coin collection sounds
- Enemy defeat sounds
- Background music
- Power-up sounds

### ✨ Polish (Planned)
- Particle effects for coin collection
- Better sprite graphics instead of colored rectangles
- More enemy types (Goombas, Koopa Troopas)
- Multiple levels
- Menu system
- High score saving

### 🎯 Additional Features (Ideas)
- Fire flower power-up
- Warp pipes
- Secret areas
- Boss battles
- Multiplayer support

## Technical Notes

### Performance
- Uses SpriteKit's built-in physics engine
- Efficient collision detection with category bit masks
- Smooth 60fps gameplay on modern iOS devices

### Code Structure
- Object-oriented design with separate classes for each game element
- Physics-based movement and collision detection
- Modular level generation system
- Extensible enemy and power-up systems

## Troubleshooting

### Common Issues
1. **Game not responding to touch**: Make sure you're tapping the colored control buttons
2. **Player falling through ground**: Check that physics bodies are properly set up
3. **Camera not following**: Ensure the camera target is set to the player
4. **Poor performance**: Try running on device instead of simulator

### Debug Features
- FPS counter visible in top-left corner
- Node count display for performance monitoring
- Physics debug drawing available (uncomment in GameViewController)

## Credits

Inspired by Nintendo's Super Mario World. This is a learning project demonstrating iOS game development with SpriteKit.

---

**Note**: This game uses simple colored rectangles as placeholders for sprites. In a production game, you would replace these with proper sprite artwork and animations.
