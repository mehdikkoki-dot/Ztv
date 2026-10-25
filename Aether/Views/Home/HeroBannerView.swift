import SwiftUI

public struct HeroBannerView: View {
    public let title: String
    public let subtitle: String
    public let backdropUrl: String
    public let rating: String
    public let onPlay: () -> Void
    public let onMoreInfo: () -> Void
    
    public init(title: String, subtitle: String, backdropUrl: String, rating: String, onPlay: @escaping () -> Void, onMoreInfo: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.backdropUrl = backdropUrl
        self.rating = rating
        self.onPlay = onPlay
        self.onMoreInfo = onMoreInfo
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Ambient Backlight Glow
            RadialGradient(
                colors: [Color.red.opacity(0.35), Color.purple.opacity(0.2), Color.clear],
                center: .top,
                startRadius: 10,
                endRadius: 300
            )
            .frame(height: 500)
            
            // Backdrop Image with Async Image
            AsyncImage(url: URL(string: backdropUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 500)
                        .clipped()
                default:
                    Color.black.opacity(0.8)
                        .frame(height: 500)
                }
            }
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.3),
                        .init(color: Color(hex: 0x0A0A0C).opacity(0.8), location: 0.75),
                        .init(color: Color(hex: 0x0A0A0C), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Content Information
            VStack(alignment: .leading, spacing: 10) {
                // Badges
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 11))
                        Text(rating)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .appleGlass(cornerRadius: 10)
                    
                    Text("4K HDR")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .appleGlass(cornerRadius: 8)
                    
                    Text("Dolby Atmos")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.purple.opacity(0.9))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .appleGlass(cornerRadius: 8)
                }
                
                // Title (Optical Typography tightened tracking)
                Text(title)
                    .font(.system(size: 32, weight: .black, design: .default))
                    .tracking(-0.8)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Description
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
                    .lineSpacing(3)
                
                // Actions
                HStack(spacing: 12) {
                    Button(action: onPlay) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15))
                            Text("مشاهدة الآن")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .white.opacity(0.2), radius: 10, y: 4)
                    }
                    .appleTactile()
                    
                    Button(action: onMoreInfo) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18))
                            .frame(width: 48, height: 48)
                            .appleGlass(cornerRadius: 16)
                            .foregroundColor(.white)
                    }
                    .appleTactile()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}
