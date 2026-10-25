import SwiftUI

public struct MediaDetailView: View {
    public let media: UnifiedMedia
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedEpisodeNumber: Int = 1
    @State private var resolvedStreams: [ResolvedStream] = []
    @State private var isResolvingStreams = true
    @State private var activeStream: ResolvedStream? = nil
    
    var episodes: [UnifiedEpisode] {
        NetflixCatalog.getEpisodes(for: media, season: 1)
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                
                // BACKDROP & CLOSE
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: media.backdropUrl)) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 260)
                                .clipped()
                        default:
                            Color(hex: 0x121217)
                                .frame(height: 260)
                        }
                    }
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color(hex: 0x121217)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .appleGlass(cornerRadius: 18)
                            .padding(16)
                    }
                    .appleTactile()
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    // Title & Badges
                    Text(media.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text("★ \(String(format: "%.1f", media.rating))")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .appleGlass(cornerRadius: 8)
                        
                        Text("\(media.year)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(media.isSeries ? "مسلسل" : "فيلم")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .appleGlass(cornerRadius: 8)
                        
                        Text("4K HDR")
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundColor(.purple.opacity(0.8))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .appleGlass(cornerRadius: 8)
                    }
                    
                    // Overview
                    Text(media.overview)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.75))
                        .lineSpacing(4)
                    
                    // EPISODES SELECTOR (IF SERIES)
                    if media.isSeries {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("اختر الحلقة")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(episodes) { ep in
                                        Button(action: {
                                            self.selectedEpisodeNumber = ep.episodeNumber
                                            triggerStreamResolution()
                                        }) {
                                            Text(ep.title)
                                                .font(.system(size: 12, weight: selectedEpisodeNumber == ep.episodeNumber ? .bold : .medium))
                                                .foregroundColor(selectedEpisodeNumber == ep.episodeNumber ? .black : .white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(selectedEpisodeNumber == ep.episodeNumber ? Color.white : Color.white.opacity(0.1))
                                                .cornerRadius(12)
                                        }
                                        .appleTactile()
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // MULTI-SOURCE RESOLVED STREAMS SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("السيرفرات المتاحة للتشغيل")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !isResolvingStreams {
                                Text("\(resolvedStreams.count) سيرفرات جاهزة")
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(.emeraldGreen)
                            }
                        }
                        
                        if isResolvingStreams {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("جاري فحص وتجميع الروابط من كافة السيرفرات في الخلفية...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 14)
                        } else {
                            ForEach(resolvedStreams) { stream in
                                Button(action: {
                                    self.activeStream = stream
                                }) {
                                    HStack(spacing: 14) {
                                        // Quality Badge
                                        Text(stream.quality.contains("1080") ? "1080p" : (stream.quality.contains("720") ? "720p" : "FAST"))
                                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(width: 48, height: 44)
                                            .background(
                                                LinearGradient(
                                                    colors: stream.quality.contains("1080") ? [.indigo, .purple] : [Color.white.opacity(0.18), Color.white.opacity(0.08)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(stream.serverName)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            HStack(spacing: 6) {
                                                Text("المصدر: \(stream.providerName)")
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(.emeraldGreen)
                                                
                                                if let ping = stream.pingMs {
                                                    Text("• الاستجابة: \(ping)ms")
                                                        .font(.system(size: 10, design: .monospaced))
                                                        .foregroundColor(.white.opacity(0.4))
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(.white)
                                    }
                                    .padding(12)
                                    .appleGlass(cornerRadius: 16)
                                }
                                .appleTactile()
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: 0x121217).ignoresSafeArea())
        .onAppear {
            triggerStreamResolution()
        }
        .fullScreenCover(item: $activeStream) { stream in
            PlayerView(
                stream: stream,
                title: media.isSeries ? "\(media.title) - الحلقة \(selectedEpisodeNumber)" : media.title
            )
        }
    }
    
    private func triggerStreamResolution() {
        isResolvingStreams = true
        Task {
            let streams = await MultiSourceResolver.shared.resolveStreams(
                for: media.title,
                episodeNumber: media.isSeries ? selectedEpisodeNumber : nil
            )
            await MainActor.run {
                self.resolvedStreams = streams
                self.isResolvingStreams = false
            }
        }
    }
}
