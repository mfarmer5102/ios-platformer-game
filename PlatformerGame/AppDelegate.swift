import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("AppDelegate: didFinishLaunchingWithOptions called")
        
        // Create the window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create the main storyboard and initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        
        print("AppDelegate: Initial view controller: \(String(describing: initialViewController))")
        
        // Set the root view controller
        window?.rootViewController = initialViewController
        
        // Make the window visible
        window?.makeKeyAndVisible()
        
        print("AppDelegate: Window setup complete")
        
        return true
    }
}
