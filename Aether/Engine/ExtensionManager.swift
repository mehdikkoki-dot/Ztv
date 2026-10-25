import Foundation
import Combine

public class ExtensionManager: ObservableObject {
    public static let shared = ExtensionManager()
    
    @Published public var availablePlugins: [CloudIOSPlugin] = []
    @Published public var activePluginName: String = "Akwam"
    @Published public var currentSections: [PluginSection] = []
    @Published public var isLoadingFeed: Bool = false
    @Published public var currentRepoUrl: String = "https://raw.githubusercontent.com/mehdikkoki-dot/T/main/repo.json"
    
    private let fileManager = FileManager.default
    private var pluginsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("Plugins", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    public init() {
        bootstrapDefaultPlugins()
    }
    
    /// Bootstraps Akwam and FaselHD plugins from bundle or fallback
    private func bootstrapDefaultPlugins() {
        Task {
            // First check if repo is available
            await self.fetchRepo(from: self.currentRepoUrl)
            
            // Load Akwam by default
            await self.activatePlugin(named: "Akwam")
        }
    }
    
    /// Fetches the repo list from mehdikkoki-dot/T/main/repo.json
    public func fetchRepo(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let plugins = try JSONDecoder().decode([CloudIOSPlugin].self, from: data)
            await MainActor.run {
                self.availablePlugins = plugins
            }
        } catch {
            print("⚠️ [ExtensionManager] Failed to fetch repo.json: \(error)")
        }
    }
    
    /// Activates a plugin by downloading or reading its JS file and refreshing the feed
    public func activatePlugin(named name: String) async {
        await MainActor.run {
            self.isLoadingFeed = true
            self.activePluginName = name
        }
        
        var jsCode = ""
        
        // 1. Try local cached file
        let localFile = pluginsDirectory.appendingPathComponent("\(name).js")
        if let localData = try? Data(contentsOf: localFile), let content = String(data: localData, encoding: .utf8) {
            jsCode = content
        } else if let bundleUrl = Bundle.main.url(forResource: name, withExtension: "js", subdirectory: "Plugins"),
                  let bundleData = try? Data(contentsOf: bundleUrl),
                  let content = String(data: bundleData, encoding: .utf8) {
            jsCode = content
        } else {
            // 2. Fetch directly from mehdikkoki-dot/T repository
            let scriptUrl = "https://raw.githubusercontent.com/mehdikkoki-dot/T/main/\(name).js"
            if let url = URL(string: scriptUrl), let (data, _) = try? await URLSession.shared.data(from: url),
               let content = String(data: data, encoding: .utf8) {
                jsCode = content
                try? data.write(to: localFile)
            }
        }
        
        guard !jsCode.isEmpty else {
            await MainActor.run { self.isLoadingFeed = false }
            return
        }
        
        // 3. Load script into JSRuntime and fetch live sections
        JSRuntime.shared.loadPlugin(code: jsCode)
        let sections = JSRuntime.shared.getMainPage()
        
        await MainActor.run {
            self.currentSections = sections
            self.isLoadingFeed = false
        }
    }
}
