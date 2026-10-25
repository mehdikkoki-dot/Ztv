import SwiftUI
import AVKit

public struct PlayerView: View {
    public let stream: PluginStreamLink
    public let title: String
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer?
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // HUD Top Bar
            VStack {
                HStack {
                    Button(action: {
                        player?.pause()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .appleGlass(cornerRadius: 22)
                    }
                    .appleTactile()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(stream.name)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.emeraldGreen)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: stream.url) else { return }
        
        var options: [String: Any] = [:]
        if let headers = stream.headers {
            options["AVURLAssetHTTPHeaderFieldsKey"] = headers
        }
        
        let asset = AVURLAsset(url: url, options: options)
        let playerItem = AVPlayerItem(asset: asset)
        let avPlayer = AVPlayer(playerItem: playerItem)
        self.player = avPlayer
        avPlayer.play()
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
