import Foundation

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
    
    public init(id: String, title: String, originalTitle: String? = nil, posterUrl: String, backdropUrl: String, rating: Double, year: Int, overview: String, isSeries: Bool, seasonsCount: Int? = 1, category: String, searchKeywords: [String] = []) {
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
    case cleanEmbed   // Sandboxed Ad-Blocked Web Player (Dood, Streamtape, Fasel Player)
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
        self.id = "\(providerName)-\(serverName)-\(url.hashValue)"
        self.serverName = serverName
        self.providerName = providerName
        self.quality = quality
        self.url = url
        self.streamType = streamType
        self.headers = headers
        self.pingMs = pingMs
    }
}
