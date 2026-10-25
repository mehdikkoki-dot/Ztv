import SwiftUI
import AVKit

public struct PlayerView: View {
    public let stream: StreamSource
    public let title: String
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer?
    @State private var isPlaying = true
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Video Player
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Custom HUD Overlay
            VStack {
                // Top Bar
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
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(stream.serverName) • \(stream.quality)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.emeraldGreen)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("CC")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .appleGlass(cornerRadius: 22)
                    }
                    .appleTactile()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .onAppear {
            if let url = URL(string: stream.url) {
                let avPlayer = AVPlayer(url: url)
                self.player = avPlayer
                avPlayer.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
