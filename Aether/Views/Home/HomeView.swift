import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var extensionManager: ExtensionManager
    @State private var selectedItem: PluginCardItem? = nil
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Top Header with Plugin Selector
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Ztv")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("CloudiOS Extensions Engine")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        
                        // Active Server Badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.emeraldGreen)
                                .frame(width: 8, height: 8)
                            Text(extensionManager.activePluginName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .appleGlass(cornerRadius: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Horizontal Fast Server Pills (Akwam, FaselHD, MyCima, etc.)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["Akwam", "Faselhd", "MyCimaProvider", "Shahid4u", "Wecima", "Witanime", "Egydead", "3isk"], id: \.self) { name in
                                Button(action: {
                                    Task {
                                        await extensionManager.activatePlugin(named: name)
                                    }
                                }) {
                                    Text(name)
                                        .font(.system(size: 12, weight: extensionManager.activePluginName == name ? .bold : .medium))
                                        .foregroundColor(extensionManager.activePluginName == name ? .black : .white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(extensionManager.activePluginName == name ? Color.white : Color.white.opacity(0.08))
                                        .clipShape(Capsule())
                                }
                                .appleTactile()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Live Content from Extension
                if extensionManager.isLoadingFeed {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        Text("جاري سحب المحتوى المباشر من سيرفر \(extensionManager.activePluginName)...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                } else if extensionManager.currentSections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.4))
                        Text("لم يتم العثور على أقسام، يرجى التحقق من الاتصال أو تبديل السيرفر")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                } else {
                    // Render Sections dynamically from the active plugin
                    ForEach(extensionManager.currentSections) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(section.items) { item in
                                        Button(action: {
                                            self.selectedItem = item
                                        }) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                AsyncImage(url: URL(string: item.posterUrl ?? "")) { phase in
                                                    switch phase {
                                                    case .success(let img):
                                                        img
                                                            .resizable()
                                                            .aspectRatio(2/3, contentMode: .fill)
                                                            .frame(width: 140, height: 210)
                                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                    default:
                                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                            .fill(Color.white.opacity(0.1))
                                                            .frame(width: 140, height: 210)
                                                            .overlay(
                                                                Image(systemName: "film")
                                                                    .foregroundColor(.white.opacity(0.3))
                                                            )
                                                    }
                                                }
                                                
                                                Text(item.name)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .frame(width: 140, alignment: .leading)
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
            .padding(.bottom, 100)
        }
        .background(Color(hex: 0x0A0A0C).ignoresSafeArea())
        .sheet(item: $selectedItem) { item in
            MediaDetailView(item: item)
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
