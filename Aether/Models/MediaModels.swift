import Foundation

// MARK: - CloudiOS Scraper Extension & Plugin Models

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
    
    public init(name: String, url: String, posterUrl: String? = nil) {
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
    
    public init(name: String? = nil, url: String, episode: Int? = nil, posterUrl: String? = nil) {
        self.name = name
        self.url = url
        self.episode = episode
        self.posterUrl = posterUrl
    }
}

public struct PluginMediaDetail: Codable {
    public let name: String
    public let url: String
    public let posterUrl: String?
    public let plot: String?
    public let year: Int?
    public let type: String?
    public let episodes: [PluginEpisode]?
    
    public init(name: String, url: String, posterUrl: String? = nil, plot: String? = nil, year: Int? = nil, type: String? = nil, episodes: [PluginEpisode]? = nil) {
        self.name = name
        self.url = url
        self.posterUrl = posterUrl
        self.plot = plot
        self.year = year
        self.type = type
        self.episodes = episodes
    }
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

// MARK: - Unified Netflix-Grade Media Models

public enum MediaCategory: String, CaseIterable, Identifiable {
    case trending = "الأكثر رواجاً اليوم"
    case latestMovies = "أحدث أفلام 2024 - 2025"
    case topSeries = "أقوى المسلسلات الحصرية"
    case arabic = "أفلام ومسلسلات عربية"
    case anime = "أنمي مترجم"
    
    public var id: String { rawValue }
}

public struct UnifiedMedia: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let originalTitle: String?
    public let posterUrl: String
    public let backdropUrl: String
    public let rating: Double
    public let year: Int
    public let overview: String
    public let isSeries: Bool
    public let seasonsCount: Int?
    public let category: String
    public let searchKeywords: [String]
    public let tmdbId: String?
    public let imdbId: String?
    
    public init(
        id: String,
        title: String,
        originalTitle: String? = nil,
        posterUrl: String,
        backdropUrl: String,
        rating: Double,
        year: Int,
        overview: String,
        isSeries: Bool,
        seasonsCount: Int? = 1,
        category: String,
        searchKeywords: [String] = [],
        tmdbId: String? = nil,
        imdbId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.posterUrl = posterUrl
        self.backdropUrl = backdropUrl
        self.rating = rating
        self.year = year
        self.overview = overview
        self.isSeries = isSeries
        self.seasonsCount = seasonsCount
        self.category = category
        self.searchKeywords = searchKeywords.isEmpty ? [title, originalTitle ?? ""].filter { !$0.isEmpty } : searchKeywords
        self.tmdbId = tmdbId
        self.imdbId = imdbId
    }
}

public struct UnifiedEpisode: Identifiable, Codable, Hashable {
    public let id: String
    public let seasonNumber: Int
    public let episodeNumber: Int
    public let title: String
    public let thumbnail: String?
    
    public init(seasonNumber: Int, episodeNumber: Int, title: String? = nil, thumbnail: String? = nil) {
        self.id = "s\(seasonNumber)e\(episodeNumber)"
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.title = title ?? "الحلقة \(episodeNumber)"
        self.thumbnail = thumbnail
    }
}

public enum StreamType: String, Codable {
    case directHLS    // Direct .m3u8 stream
    case directMP4    // Direct .mp4 video
    case cleanEmbed   // Sandboxed Ad-Blocked Web Player (AutoEmbed, MultiEmbed, VidSrc, Dood, Streamwish)
}

public struct ResolvedStream: Identifiable, Codable, Hashable {
    public let id: String
    public let serverName: String
    public let providerName: String
    public let quality: String
    public let url: String
    public let streamType: StreamType
    public let headers: [String: String]?
    public let pingMs: Int?
    
    public init(serverName: String, providerName: String, quality: String, url: String, streamType: StreamType, headers: [String: String]? = nil, pingMs: Int? = nil) {
        self.id = "\(providerName)-\(serverName)-\(abs(url.hashValue))"
        self.serverName = serverName
        self.providerName = providerName
        self.quality = quality
        self.url = url
        self.streamType = streamType
        self.headers = headers
        self.pingMs = pingMs
    }
}
