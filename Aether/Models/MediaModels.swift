import Foundation

// MARK: - Core Media Models
public enum MediaType: String, Codable {
    case movie
    case tvSeries
    case anime
}

public struct MediaItem: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let posterUrl: String?
    public let backdropUrl: String?
    public let rating: Double?
    public let year: Int?
    public let overview: String?
    public let type: MediaType
    public let providerId: String
    
    public init(id: String, title: String, posterUrl: String?, backdropUrl: String?, rating: Double?, year: Int?, overview: String?, type: MediaType, providerId: String) {
        self.id = id
        self.title = title
        self.posterUrl = posterUrl
        self.backdropUrl = backdropUrl
        self.rating = rating
        self.year = year
        self.overview = overview
        self.type = type
        self.providerId = providerId
    }
}

public struct Episode: Identifiable, Codable, Hashable {
    public let id: String
    public let season: Int
    public let episodeNumber: Int
    public let title: String?
    public let thumbnail: String?
    public let duration: String?
    
    public init(id: String, season: Int, episodeNumber: Int, title: String? = nil, thumbnail: String? = nil, duration: String? = nil) {
        self.id = id
        self.season = season
        self.episodeNumber = episodeNumber
        self.title = title
        self.thumbnail = thumbnail
        self.duration = duration
    }
}

public struct StreamSource: Identifiable, Codable, Hashable {
    public let id: String
    public let serverName: String
    public let quality: String
    public let url: String
    public let headers: [String: String]?
    public let isHLS: Bool
    public let pingMs: Int?
    
    public init(id: String = UUID().uuidString, serverName: String, quality: String, url: String, headers: [String: String]? = nil, isHLS: Bool = true, pingMs: Int? = nil) {
        self.id = id
        self.serverName = serverName
        self.quality = quality
        self.url = url
        self.headers = headers
        self.isHLS = isHLS
        self.pingMs = pingMs
    }
}

// MARK: - Extension & Repo Manifest Models
public struct ExtensionManifest: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let version: String
    public let author: String?
    public let description: String?
    public let iconUrl: String?
    public let baseUrl: String
    public let scriptUrl: String
    public var isInstalled: Bool?
    public var isEnabled: Bool?
}

public struct RepoManifest: Codable {
    public let repositoryName: String
    public let description: String?
    public let version: Int
    public let extensions: [ExtensionManifest]
}
