import SwiftUI

@main
struct AetherApp: App {
    @StateObject private var extensionManager = ExtensionManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(extensionManager)
        }
    }
}
