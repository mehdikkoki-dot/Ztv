/**
 * Sample Provider Extension for Ztv / CloudiOS
 * Use this template to create new scrapers for any movie or series website.
 */

var MIRRORS = [
    "https://example.com",
    "https://example.to"
];

function getActiveUrl() {
    for (var i = 0; i < MIRRORS.length; i++) {
        var test = httpGet(MIRRORS[i]);
        if (test && test.length > 50) {
            return MIRRORS[i];
        }
    }
    return MIRRORS[0];
}

var MAIN_URL = getActiveUrl();

function getMainPage() {
    var sections = [];
    var html = httpGet(MAIN_URL);
    if (!html) return sections;
    
    var items = [];
    var regex = /<article[^>]*>[\s\S]*?<a\s+href="([^"]+)"[^>]*>[\s\S]*?<img\s+src="([^"]+)"[^>]*>[\s\S]*?<h2[^>]*>([^<]+)<\/h2>/gi;
    var match;
    while ((match = regex.exec(html)) !== null) {
        items.push({
            name: match[3].trim(),
            url: match[1],
            posterUrl: match[2]
        });
    }
    
    sections.push({ name: "أحدث الإضافات", items: items });
    return sections;
}

function search(query) {
    if (!query) return [];
    var searchUrl = MAIN_URL + "/search?q=" + encodeURIComponent(query);
    var html = httpGet(searchUrl);
    if (!html) return [];
    
    var results = [];
    var regex = /<div class="result-item"[^>]*>[\s\S]*?<a href="([^"]+)"[^>]*>[\s\S]*?<img src="([^"]+)"[^>]*>[\s\S]*?<h3[^>]*>([^<]+)<\/h3>/gi;
    var match;
    while ((match = regex.exec(html)) !== null) {
        results.push({
            name: match[3].trim(),
            url: match[1],
            posterUrl: match[2]
        });
    }
    return results;
}

function load(url) {
    var html = httpGet(url);
    if (!html) return null;
    
    var titleMatch = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i);
    var title = titleMatch ? titleMatch[1].replace(/<[^>]+>/g, "").trim() : "Unknown";
    
    var posterMatch = html.match(/<img[^>]*class="poster"[^>]*src="([^"]+)"/i);
    var poster = posterMatch ? posterMatch[1] : undefined;
    
    var plotMatch = html.match(/<div class="story"[^>]*>([\s\S]*?)<\/div>/i);
    var plot = plotMatch ? plotMatch[1].replace(/<[^>]+>/g, "").trim() : "";
    
    var episodes = [];
    var epRegex = /<a\s+href="([^"]+)" class="ep-link"[^>]*>([^<]+)<\/a>/gi;
    var epMatch;
    var index = 1;
    while ((epMatch = epRegex.exec(html)) !== null) {
        episodes.push({
            name: epMatch[2].trim(),
            url: epMatch[1],
            episode: index++,
            posterUrl: poster
        });
    }
    
    return {
        name: title,
        url: url,
        posterUrl: poster,
        plot: plot,
        year: 2024,
        type: episodes.length > 0 ? "tvSeries" : "movie",
        episodes: episodes
    };
}

function loadLinks(url) {
    var html = httpGet(url);
    if (!html) return [];
    
    var links = [];
    
    // 1. Direct MP4 / HLS Streams
    var videoRegex = /<source\s+[^>]*src="([^"]+)"[^>]*>/gi;
    var match;
    while ((match = videoRegex.exec(html)) !== null) {
        var vUrl = match[1];
        links.push({
            name: "سيرفر مباشر عالي السرعة",
            url: vUrl,
            headers: { "Referer": url }
        });
    }
    
    // 2. Sandboxed Embed Players
    var iframeRegex = /<iframe[^>]*src="([^"]+)"/gi;
    while ((match = iframeRegex.exec(html)) !== null) {
        var emb = match[1];
        if (emb.indexOf("http") === 0) {
            links.push({
                name: "سيرفر Embed نظيف",
                url: emb
            });
        }
    }
    
    return links;
}
