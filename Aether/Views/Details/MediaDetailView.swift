import SwiftUI

public struct MediaDetailView: View {
    public let media: MediaItem
    @Environment(\.dismiss) var dismiss
    @State private var activeStream: StreamSource? = nil
    
    // Sample extracted streams
    let availableStreams = [
        StreamSource(
            serverName: "Vidcloud Direct Stream",
            quality: "4K (2160p)",
            url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
            headers: ["Referer": "https://vidcloud.co/"],
            isHLS: true,
            pingMs: 38
        ),
        StreamSource(
            serverName: "Streamtape Decrypted",
            quality: "1080p Full HD",
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            isHLS: false,
            pingMs: 54
        ),
        StreamSource(
            serverName: "Filemoon Fast Server",
            quality: "720p Mobile",
            url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
            isHLS: true,
            pingMs: 92
        )
    ]
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Backdrop & Close Button
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: media.backdropUrl ?? "")) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipped()
                        default:
                            Color.black.opacity(0.8)
                                .frame(height: 240)
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
                    // Title & Metadata
                    Text(media.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text("★ \(String(format: "%.1f", media.rating ?? 0.0))")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .appleGlass(cornerRadius: 8)
                        
                        if let year = media.year {
                            Text("\(year)")
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Text(media.type.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .appleGlass(cornerRadius: 8)
                    }
                    
                    // Overview
                    if let overview = media.overview {
                        Text(overview)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(4)
                    }
                    
                    // STREAM SOURCE INSPECTOR (The Core Masterpiece)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("سيرفرات البث المفككة (Extracted Streams)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(availableStreams.count) مصادر")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.emeraldGreen)
                        }
                        .padding(.top, 8)
                        
                        ForEach(availableStreams) { stream in
                            Button(action: {
                                self.activeStream = stream
                            }) {
                                HStack(spacing: 14) {
                                    // Quality badge
                                    Text(stream.quality.contains("4K") ? "4K" : "HD")
                                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                                        .foregroundColor(stream.quality.contains("4K") ? .white : .white.opacity(0.8))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            stream.quality.contains("4K")
                                            ? LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stream.serverName)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        HStack(spacing: 8) {
                                            Text(stream.quality)
                                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                .foregroundColor(.white.opacity(0.5))
                                            
                                            if let ping = stream.pingMs {
                                                Text("• \(ping)ms")
                                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                    .foregroundColor(.emeraldGreen)
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
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: 0x121217).ignoresSafeArea())
        .fullScreenCover(item: $activeStream) { stream in
            PlayerView(stream: stream, title: media.title)
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
