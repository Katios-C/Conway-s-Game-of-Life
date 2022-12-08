import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = UIHostingController(
            rootView: ContentView()
        )
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}
