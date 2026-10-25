import SwiftUI

public struct MediaDetailView: View {
    public let item: PluginCardItem
    @Environment(\.dismiss) var dismiss
    
    @State private var detail: PluginMediaDetail? = nil
    @State private var streamLinks: [PluginStreamLink] = []
    @State private var isLoading = true
    @State private var activeStream: PluginStreamLink? = nil
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Header with Backdrop / Poster
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: detail?.posterUrl ?? item.posterUrl ?? "")) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 260)
                                .clipped()
                        default:
                            Color.black.opacity(0.8)
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
                    // Title
                    Text(detail?.name.isEmpty == false ? detail!.name : item.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    if let year = detail?.year {
                        Text("\(year)")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Synopsis / Plot
                    if let plot = detail?.plot, !plot.isEmpty {
                        Text(plot)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(4)
                    }
                    
                    // Episodes list (if Series)
                    if let episodes = detail?.episodes, !episodes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("الحلقات (\(episodes.count))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(episodes) { ep in
                                        Button(action: {
                                            fetchStreams(for: ep.url)
                                        }) {
                                            Text(ep.name ?? "حلقة")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .appleGlass(cornerRadius: 12)
                                        }
                                        .appleTactile()
                                    }
                                }
                            }
                        }
                    }
                    
                    // STREAM LINKS SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("سيرفرات التشغيل المستخرجة")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("جاري فك تشفير روابط السيرفرات الحية...")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 10)
                        } else if streamLinks.isEmpty {
                            Text("لم يتم العثور على روابط تشغيل مباشرة لهذا العنصر.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        } else {
                            ForEach(streamLinks) { link in
                                Button(action: {
                                    self.activeStream = link
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.emeraldGreen)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(link.name)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("رابط تشغيل مباشر • استجابة سريعة")
                                                .font(.system(size: 10))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .appleGlass(cornerRadius: 14)
                                }
                                .appleTactile()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color(hex: 0x121217).ignoresSafeArea())
        .onAppear {
            loadDetails()
        }
        .fullScreenCover(item: $activeStream) { stream in
            PlayerView(stream: stream, title: detail?.name ?? item.name)
        }
    }
    
    private func loadDetails() {
        Task.detached {
            let loaded = JSRuntime.shared.load(url: item.url)
            let links = JSRuntime.shared.loadLinks(url: item.url)
            await MainActor.run {
                self.detail = loaded
                self.streamLinks = links
                self.isLoading = false
            }
        }
    }
    
    private func fetchStreams(for url: String) {
        isLoading = true
        Task.detached {
            let links = JSRuntime.shared.loadLinks(url: url)
            await MainActor.run {
                self.streamLinks = links
                self.isLoading = false
            }
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
