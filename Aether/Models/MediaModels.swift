import Foundation

// MARK: - CloudiOS Unified Plugin Models (Compatible with mehdikkoki-dot/T)

public struct CloudIOSPlugin: Identifiable, Codable, Hashable {
    public var id: String { name }
    public let name: String
    public let url: String
    public var isInstalled: Bool?
    public var isEnabled: Bool?
    
    public init(name: String, url: String, isInstalled: Bool? = false, isEnabled: Bool? = false) {
        self.name = name
        self.url = url
        self.isInstalled = isInstalled
        self.isEnabled = isEnabled
    }
}

public struct PluginCardItem: Identifiable, Codable, Hashable {
    public var id: String { url }
    public let name: String
    public let url: String
    public let posterUrl: String?
    
    public init(name: String, url: String, posterUrl: String?) {
        self.name = name
        self.url = url
        self.posterUrl = posterUrl
    }
}

public struct PluginSection: Identifiable, Codable, Hashable {
    public var id: String { name }
    public let name: String
    public let items: [PluginCardItem]
    
    public init(name: String, items: [PluginCardItem]) {
        self.name = name
        self.items = items
    }
}

public struct PluginEpisode: Identifiable, Codable, Hashable {
    public var id: String { url }
    public let name: String?
    public let url: String
    public let episode: Int?
    public let posterUrl: String?
}

public struct PluginMediaDetail: Codable {
    public let name: String
    public let url: String
    public let posterUrl: String?
    public let plot: String?
    public let year: Int?
    public let type: String?
    public let episodes: [PluginEpisode]?
}

public struct PluginStreamLink: Identifiable, Codable, Hashable {
    public var id: String { url }
    public let name: String
    public let url: String
    public let headers: [String: String]?
    
    public init(name: String, url: String, headers: [String: String]? = nil) {
        self.name = name
        self.url = url
        self.headers = headers
    }
}
