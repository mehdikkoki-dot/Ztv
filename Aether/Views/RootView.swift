import SwiftUI

public struct RootView: View {
    @State private var selectedTab = 0
    
    public init() {
        // Customize TabBar appearance for translucent frosted glass
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.6)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "play.tv.fill")
                }
                .tag(0)
            
            UnifiedSearchView()
                .tabItem {
                    Label("البحث الموحد", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            ExtensionsView()
                .tabItem {
                    Label("الإضافات (45)", systemImage: "puzzlepiece.extension.fill")
                }
                .tag(2)
        }
        .accentColor(.red)
        .preferredColorScheme(.dark)
    }
}
