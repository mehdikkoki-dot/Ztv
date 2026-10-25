import SwiftUI
import AVKit

public struct PlayerView: View {
    public let stream: ResolvedStream
    public let title: String
    @Environment(\.dismiss) var dismiss
    
    @State private var avPlayer: AVPlayer?
    @State private var isPlaying = true
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Dual Engine Playback
            if stream.streamType == .cleanEmbed {
                CleanWebPlayerView(urlString: stream.url)
                    .ignoresSafeArea()
            } else {
                if let player = avPlayer {
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        Text("جاري تشغيل البث المباشر...")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // HUD Top Bar
            VStack {
                HStack(alignment: .center) {
                    Button(action: {
                        avPlayer?.pause()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .appleGlass(cornerRadius: 20)
                    }
                    .appleTactile()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Text(stream.providerName)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.emeraldGreen)
                            Text("• \(stream.quality)")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .onAppear {
            setupNativePlayer()
        }
        .onDisappear {
            avPlayer?.pause()
            avPlayer = nil
        }
    }
    
    private func setupNativePlayer() {
        guard stream.streamType != .cleanEmbed else { return }
        guard let url = URL(string: stream.url) else { return }
        
        var options: [String: Any] = [:]
        if let headers = stream.headers {
            options["AVURLAssetHTTPHeaderFieldsKey"] = headers
        }
        
        let asset = AVURLAsset(url: url, options: options)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        self.avPlayer = player
        player.play()
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
