import SwiftUI

public struct UnifiedSearchView: View {
    @State private var searchText: String = ""
    @State private var selectedMedia: UnifiedMedia? = nil
    
    var filteredItems: [UnifiedMedia] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return NetflixCatalog.allItems
        }
        return NetflixCatalog.allItems.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            (item.originalTitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            item.searchKeywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Search Input Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                        
                        TextField("ابحث عن أي فيلم، مسلسل، أو أنمي...", text: $searchText)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Results Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text(searchText.isEmpty ? "أفضل الاقتراحات لك" : "نتائج البحث الموحد (\(filteredItems.count))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                            ForEach(filteredItems) { item in
                                Button(action: {
                                    self.selectedMedia = item
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        AsyncImage(url: URL(string: item.posterUrl)) { phase in
                                            switch phase {
                                            case .success(let img):
                                                img
                                                    .resizable()
                                                    .aspectRatio(2/3, contentMode: .fill)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            default:
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.white.opacity(0.08))
                                                    .aspectRatio(2/3, contentMode: .fill)
                                            }
                                        }
                                        
                                        Text(item.title)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                }
                                .appleTactile()
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 120)
            }
            .background(Color(hex: 0x0A0A0C).ignoresSafeArea())
            .navigationTitle("البحث الموحد")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedMedia) { media in
                MediaDetailView(media: media)
            }
        }
    }
}
