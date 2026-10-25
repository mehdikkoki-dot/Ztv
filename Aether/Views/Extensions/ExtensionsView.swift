import SwiftUI

public struct ExtensionsView: View {
    @EnvironmentObject var extensionManager: ExtensionManager
    @State private var repoUrlInput = ""
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Repository Config Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("مستودع إضافات CloudiOS (mehdikkoki-dot/T)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("يتم تحميل الإضافات مباشرة من مستودعك الخاص (45 موقع عربي وأجنبي).")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 8) {
                            TextField("رابط repo.json", text: $repoUrlInput)
                                .font(.system(size: 11, design: .monospaced))
                                .padding(10)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                Task {
                                    await extensionManager.fetchRepo(from: repoUrlInput.isEmpty ? extensionManager.currentRepoUrl : repoUrlInput)
                                }
                            }) {
                                Text("تحديث")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.indigo)
                                    .cornerRadius(10)
                            }
                            .appleTactile()
                        }
                    }
                    .padding(16)
                    .appleGlass(cornerRadius: 18)
                    .padding(.horizontal, 20)
                    
                    // Available Plugins List
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("الإضافات المتوفرة بالمستودع (\(extensionManager.availablePlugins.count))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        ForEach(extensionManager.availablePlugins) { plugin in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(extensionManager.activePluginName == plugin.name ? Color.emeraldGreen : Color.white.opacity(0.3))
                                    .frame(width: 10, height: 10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(plugin.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(plugin.url)
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.4))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        await extensionManager.activatePlugin(named: plugin.name)
                                    }
                                }) {
                                    Text(extensionManager.activePluginName == plugin.name ? "نشط حالياً" : "تفعيل")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(extensionManager.activePluginName == plugin.name ? .emeraldGreen : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(extensionManager.activePluginName == plugin.name ? Color.emeraldGreen.opacity(0.15) : Color.white.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .appleTactile()
                            }
                            .padding(14)
                            .appleGlass(cornerRadius: 16)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color(hex: 0x0A0A0C).ignoresSafeArea())
            .navigationTitle("إدارة الإضافات")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.repoUrlInput = extensionManager.currentRepoUrl
        }
    }
}

private extension Color {
    static let emeraldGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
}
