import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("GameViewController: viewDidLoad called")
        
        if let view = self.view as! SKView? {
            NSLog("GameViewController: SKView found, creating GameScene")
            
            // Create the GameScene programmatically
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            NSLog("GameViewController: GameScene created, presenting scene")
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            NSLog("GameViewController: Scene presented successfully")
        } else {
            NSLog("GameViewController: ERROR - view is not an SKView!")
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
