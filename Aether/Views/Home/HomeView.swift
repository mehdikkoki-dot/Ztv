import SwiftUI

public struct HomeView: View {
    @State private var selectedMedia: UnifiedMedia? = nil
    @State private var isShowingDetail = false
    
    let featured = NetflixCatalog.featuredItem
    let allItems = NetflixCatalog.allItems
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                
                // NETFLIX-STYLE HERO BANNER
                ZStack(alignment: .bottomLeading) {
                    // Backdrop Image
                    AsyncImage(url: URL(string: featured.backdropUrl)) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 520)
                                .clipped()
                        default:
                            Color(hex: 0x121217)
                                .frame(height: 520)
                        }
                    }
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.3),
                                .init(color: Color(hex: 0x0A0A0C).opacity(0.85), location: 0.75),
                                .init(color: Color(hex: 0x0A0A0C), location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Top App Logo & Nav
                    VStack(alignment: .leading) {
                        HStack {
                            Text("ZTV")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.emeraldGreen)
                                    .frame(width: 8, height: 8)
                                Text("45 سيرفر متصل")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .appleGlass(cornerRadius: 12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                        
                        Spacer()
                    }
                    
                    // Featured Info & Actions
                    VStack(alignment: .leading, spacing: 10) {
                        // Badges
                        HStack(spacing: 8) {
                            Text("★ \(String(format: "%.1f", featured.rating))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .appleGlass(cornerRadius: 8)
                            
                            Text("\(featured.year)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .appleGlass(cornerRadius: 8)
                            
                            Text("4K HDR")
                                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                                .foregroundColor(.purple.opacity(0.9))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .appleGlass(cornerRadius: 8)
                        }
                        
                        Text(featured.title)
                            .font(.system(size: 30, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(featured.overview)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(2)
                            .lineSpacing(3)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                self.selectedMedia = featured
                                self.isShowingDetail = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16))
                                    Text("تشغيل الآن")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: .white.opacity(0.25), radius: 8, y: 3)
                            }
                            .appleTactile()
                            
                            Button(action: {
                                self.selectedMedia = featured
                                self.isShowingDetail = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16))
                                    Text("معلومات")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .appleGlass(cornerRadius: 14)
                                .foregroundColor(.white)
                            }
                            .appleTactile()
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                // NETFLIX CATEGORIES CAROUSELS
                ForEach(MediaCategory.allCases) { cat in
                    let items = allItems.filter { $0.category == cat.rawValue }
                    if !items.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(cat.rawValue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(items) { item in
                                        Button(action: {
                                            self.selectedMedia = item
                                            self.isShowingDetail = true
                                        }) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                AsyncImage(url: URL(string: item.posterUrl)) { phase in
                                                    switch phase {
                                                    case .success(let img):
                                                        img
                                                            .resizable()
                                                            .aspectRatio(2/3, contentMode: .fill)
                                                            .frame(width: 140, height: 210)
                                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    default:
                                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                            .fill(Color.white.opacity(0.08))
                                                            .frame(width: 140, height: 210)
                                                    }
                                                }
                                                .overlay(
                                                    HStack(spacing: 3) {
                                                        Image(systemName: "star.fill")
                                                            .font(.system(size: 8))
                                                            .foregroundColor(.yellow)
                                                        Text(String(format: "%.1f", item.rating))
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
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .frame(width: 140, alignment: .leading)
                                                
                                                Text(item.isSeries ? "مسلسل" : "فيلم")
                                                    .font(.system(size: 10, weight: .medium))
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
                }
            }
            .padding(.bottom, 120)
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
