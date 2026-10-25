import Foundation

/// Curated Netflix-Grade Media Catalog with Rich Metadata & Seasons/Episodes
public struct NetflixCatalog {
    public static let featuredItem = UnifiedMedia(
        id: "dune_2",
        title: "Dune: Part Two (كثيب: الجزء الثاني)",
        originalTitle: "Dune: Part Two",
        posterUrl: "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80",
        backdropUrl: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&auto=format&fit=crop&q=80",
        rating: 8.6,
        year: 2024,
        overview: "يتحد بول أتريديس مع تشاني وشعب الفريمن في حرب انتقامية ضد المتآمرين الذين دمروا عائلته، في مواجهة مصيرية لتحديد مستقبل الكون.",
        isSeries: false,
        category: "الأكثر رواجاً اليوم",
        searchKeywords: ["Dune", "كثيب", "Dune 2"]
    )
    
    public static let allItems: [UnifiedMedia] = [
        NetflixCatalog.featuredItem,
        UnifiedMedia(
            id: "deadpool_wolverine",
            title: "Deadpool & Wolverine",
            originalTitle: "Deadpool & Wolverine",
            posterUrl: "https://images.unsplash.com/photo-1563089145-599997674d42?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=1200&auto=format&fit=crop&q=80",
            rating: 8.0,
            year: 2024,
            overview: "يعود ديدبول في مغامرة غير مسبوقة مع ولفيرين لتغيير تاريخ عالم مارفل السينمائي بالكامل في إطار مليء بالكوميديا والأكشن الخارق.",
            isSeries: false,
            category: "أحدث أفلام 2024 - 2025",
            searchKeywords: ["Deadpool", "Wolverine", "ديدبول"]
        ),
        UnifiedMedia(
            id: "interstellar",
            title: "Interstellar : رحلة العوالم",
            originalTitle: "Interstellar",
            posterUrl: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1200&auto=format&fit=crop&q=80",
            rating: 8.8,
            year: 2014,
            overview: "يقود فريق من رواد الفضاء أهم مهمة في تاريخ البشرية بالسفر عبر ثقب دودي لاكتشاف كوكب صالح للحياة لإنقاذ البشرية من الانقراض.",
            isSeries: false,
            category: "الأكثر رواجاً اليوم",
            searchKeywords: ["Interstellar", "انترستيلر"]
        ),
        UnifiedMedia(
            id: "shogun",
            title: "Shōgun (شوجون)",
            originalTitle: "Shōgun",
            posterUrl: "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1528164344705-475426879c0d?w=1200&auto=format&fit=crop&q=80",
            rating: 8.9,
            year: 2024,
            overview: "في اليابان عام 1600، يخوض اللورد توراناغا صراعاً مصيرياً من أجل البقاء بعد تحالف أعدائه ضده في مجلس الحكام، بالتزامن مع وصول بحار إنجليزي يحمل أسراراً حاسمة.",
            isSeries: true,
            seasonsCount: 1,
            category: "أقوى المسلسلات الحصرية",
            searchKeywords: ["Shogun", "شوجون"]
        ),
        UnifiedMedia(
            id: "house_of_dragon",
            title: "House of the Dragon (بيت التنين)",
            originalTitle: "House of the Dragon",
            posterUrl: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80",
            rating: 8.5,
            year: 2024,
            overview: "قصة نشوب الحرب الأهلية المدمرة بين أفراد عائلة تارجاريان والمعروفة باسم رقصة التنانين للسيطرة على العرش الحديدي.",
            isSeries: true,
            seasonsCount: 2,
            category: "أقوى المسلسلات الحصرية",
            searchKeywords: ["House of the Dragon", "بيت التنين"]
        ),
        UnifiedMedia(
            id: "assassins_series",
            title: "الحشاشين",
            originalTitle: "El Hashashin",
            posterUrl: "https://images.unsplash.com/photo-1514539079130-25950c84af65?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1514539079130-25950c84af65?w=1200&auto=format&fit=crop&q=80",
            rating: 9.1,
            year: 2024,
            overview: "في إطار تاريخي خلال القرن الحادي عشر، يتناول المسلسل قصة حسن الصباح مؤسس جماعة الحشاشين وأخطر فرقة اغتيالات في التاريخ من قلعة ألموت.",
            isSeries: true,
            seasonsCount: 1,
            category: "أفلام ومسلسلات عربية",
            searchKeywords: ["الحشاشين", "حسن الصباح"]
        ),
        UnifiedMedia(
            id: "welad_rizk_3",
            title: "ولاد رزق 3: القاضية",
            originalTitle: "Welad Rizk 3",
            posterUrl: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&auto=format&fit=crop&q=80",
            rating: 8.2,
            year: 2024,
            overview: "بعد سنوات من الانفصال، يضطر الإخوة للعودة إلى عالم الجريمة والسرقة في عملية أخيرة هي الأخطر والأكبر في تاريخهم بمشاركة أبطال الملاكمة العالميين.",
            isSeries: false,
            category: "أفلام ومسلسلات عربية",
            searchKeywords: ["ولاد رزق", "ولاد رزق 3"]
        ),
        UnifiedMedia(
            id: "solo_leveling",
            title: "Solo Leveling (سولو ليفلينج)",
            originalTitle: "Solo Leveling",
            posterUrl: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600&auto=format&fit=crop&q=80",
            backdropUrl: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=1200&auto=format&fit=crop&q=80",
            rating: 8.7,
            year: 2024,
            overview: "في عالم تظهر فيه بوابات الوحوش، يحصل أضعف صياد في البشرية على فرصة استثنائية تمكنه من رفع مستواه واكتساب قوى خارقة لا حدود لها.",
            isSeries: true,
            seasonsCount: 1,
            category: "أنمي مترجم",
            searchKeywords: ["Solo Leveling", "سولو ليفلينج"]
        )
    ]
    
    public static func getEpisodes(for media: UnifiedMedia, season: Int = 1) -> [UnifiedEpisode] {
        guard media.isSeries else { return [] }
        return (1...10).map { ep in
            UnifiedEpisode(
                seasonNumber: season,
                episodeNumber: ep,
                title: "الحلقة \(ep)",
                thumbnail: media.backdropUrl
            )
        }
    }
}
