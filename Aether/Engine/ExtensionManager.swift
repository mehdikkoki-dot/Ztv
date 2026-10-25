import Foundation
import Combine

public class ExtensionManager: ObservableObject {
    public static let shared = ExtensionManager()
    
    @Published public var installedExtensions: [ExtensionManifest] = []
    @Published public var availableExtensions: [ExtensionManifest] = []
    @Published public var currentRepoUrl: String = "https://raw.githubusercontent.com/ztv/extensions/main/repo.json"
    @Published public var isLoading: Bool = false
    @Published public var lastLog: String = ""
    
    private let fileManager = FileManager.default
    private var extensionsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("Extensions", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    public init() {
        loadMockInitialData()
    }
    
    private func loadMockInitialData() {
        // Pre-loaded providers for instant demonstration
        let sampleManifests = [
            ExtensionManifest(
                id: "com.aether.akwam",
                name: "Akwam (أكوام)",
                version: "2.4.0",
                author: "CloudStream Community",
                description: "أكبر مكتبة أفلام ومسلسلات عربية وأجنبية مترجمة ومدبلجة بجودة 4K و 1080p.",
                iconUrl: "https://akwam.to/favicon.ico",
                baseUrl: "https://akwam.to",
                scriptUrl: "https://raw.githubusercontent.com/ztv/extensions/main/providers/akwam.js",
                isInstalled: true,
                isEnabled: true
            ),
            ExtensionManifest(
                id: "com.aether.faselhd",
                name: "FaselHD (فاصل إعلاني)",
                version: "1.8.2",
                author: "CloudStream Community",
                description: "بث مباشر وسريع للأفلام الحصرية والأنمي مع دعم متعدد لسيرفرات التحميل.",
                iconUrl: "https://www.faselhd.club/favicon.ico",
                baseUrl: "https://www.faselhd.club",
                scriptUrl: "https://raw.githubusercontent.com/ztv/extensions/main/providers/faselhd.js",
                isInstalled: true,
                isEnabled: true
            ),
            ExtensionManifest(
                id: "com.aether.mycima",
                name: "MyCima (ماي سيما)",
                version: "3.1.0",
                author: "DevTeam",
                description: "محتوى شامل للأفلام الوثائقية والمسلسلات العربية والتركية.",
                iconUrl: "https://mycima.tv/favicon.ico",
                baseUrl: "https://mycima.tv",
                scriptUrl: "https://raw.githubusercontent.com/ztv/extensions/main/providers/mycima.js",
                isInstalled: false,
                isEnabled: false
            )
        ]
        self.installedExtensions = sampleManifests.filter { $0.isInstalled == true }
        self.availableExtensions = sampleManifests
    }
    
    /// Fetch and update the repository index from GitHub
    public func fetchRepository(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        
        await MainActor.run { self.isLoading = true }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let repo = try decoder.decode(RepoManifest.self, from: data)
            
            await MainActor.run {
                self.availableExtensions = repo.extensions
                self.isLoading = false
                self.lastLog = "✔ تم جلب \(repo.extensions.count) إضافة بنجاح من المستودع."
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.lastLog = "⚠️ تعذر جلب المستودع: \(error.localizedDescription)"
            }
        }
    }
    
    /// Install an extension dynamically
    public func installExtension(_ manifest: ExtensionManifest) async {
        guard let scriptUrl = URL(string: manifest.scriptUrl) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: scriptUrl)
            let localFile = extensionsDirectory.appendingPathComponent("\(manifest.id).js")
            try data.write(to: localFile)
            
            await MainActor.run {
                var updated = manifest
                updated.isInstalled = true
                updated.isEnabled = true
                self.installedExtensions.append(updated)
                self.lastLog = "✔ تم تثبيت إضافة \(manifest.name) بنجاح."
            }
        } catch {
            await MainActor.run {
                self.lastLog = "⚠️ فشل تثبيت \(manifest.name): \(error.localizedDescription)"
            }
        }
    }
}
