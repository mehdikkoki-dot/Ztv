import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var extensionManager: ExtensionManager
    @State private var selectedMedia: MediaItem? = nil
    @State private var showingDetailSheet = false
    
    // Sample Catalog
    let trendingItems = [
        MediaItem(
            id: "interstellar",
            title: "Interstellar : رحلة العوالم",
            posterUrl: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200&auto=format&fit=crop&q=80",
            rating: 8.8,
            year: 2014,
            overview: "عندما يصبح كوكب الأرض غير صالح للعيش، يقود فريق من المستكشفين أهم مهمة في تاريخ البشرية لاكتشاف كوكب جديد بين المجرات.",
            type: .movie,
            providerId: "com.aether.akwam"
        ),
        MediaItem(
            id: "oppenheimer",
            title: "Oppenheimer",
            posterUrl: "https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=1200&auto=format&fit=crop&q=80",
            rating: 8.9,
            year: 2023,
            overview: "قصة العالم الفيزيائي روبرت أوبنهايمر ودوره في اختراع القنبلة الذرية ومشروع مانهاتن.",
            type: .movie,
            providerId: "com.aether.faselhd"
        ),
        MediaItem(
            id: "cyberpunk",
            title: "Cyberpunk: Edgerunners",
            posterUrl: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=1200&auto=format&fit=crop&q=80",
            rating: 8.4,
            year: 2022,
            overview: "شاب شوارع موهوب يسعى للنجاة في مدينة نايت سيتي المستقبلية المهووسة بالتكنولوجيا.",
            type: .anime,
            providerId: "com.aether.akwam"
        )
    ]
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Hero Banner
                if let hero = trendingItems.first {
                    HeroBannerView(
                        title: hero.title,
                        subtitle: hero.overview ?? "",
                        backdropUrl: hero.backdropUrl ?? "",
                        rating: String(format: "%.1f", hero.rating ?? 0.0),
                        onPlay: {
                            self.selectedMedia = hero
                            self.showingDetailSheet = true
                        },
                        onMoreInfo: {
                            self.selectedMedia = hero
                            self.showingDetailSheet = true
                        }
                    )
                }
                
                // Active Providers Pills
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("الإضافات المفعلة (Providers)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(extensionManager.installedExtensions.count) مصادر")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.indigo)
                    }
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(extensionManager.installedExtensions) { ext in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.emeraldGreen)
                                        .frame(width: 8, height: 8)
                                    Text(ext.name)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("v\(ext.version)")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .appleGlass(cornerRadius: 14)
                                .appleTactile()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Trending Carousel
                VStack(alignment: .leading, spacing: 12) {
                    Text("الأكثر رواجاً اليوم")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(trendingItems) { item in
                                Button(action: {
                                    self.selectedMedia = item
                                    self.showingDetailSheet = true
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        AsyncImage(url: URL(string: item.posterUrl ?? "")) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(2/3, contentMode: .fill)
                                                    .frame(width: 140, height: 210)
                                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            default:
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(width: 140, height: 210)
                                            }
                                        }
                                        .overlay(
                                            HStack(spacing: 3) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.yellow)
                                                Text(String(format: "%.1f", item.rating ?? 0.0))
                                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .appleGlass(cornerRadius: 8)
                                            .padding(8),
                                            alignment: .topTrailing
                                        )
                                        
                                        Text(item.title)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .frame(width: 140, alignment: .leading)
                                        
                                        Text(item.type.rawValue.capitalized)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .appleTactile()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color(hex: 0x0A0A0C).ignoresSafeArea())
        .sheet(item: $selectedMedia) { media in
            MediaDetailView(media: media)
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
