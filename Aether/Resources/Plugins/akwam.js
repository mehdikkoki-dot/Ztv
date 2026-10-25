/**
 * Akwam Plugin for CloudiOS (JavaScriptCore ES5)
 * Converted from Kotlin CloudStream: https://github.com/Abodabodd/re-3arabi
 * Source: https://akwam.ss
 */

var MAIN_URL = "https://ak.sv";

function cleanUrl(url) {
  try {
    if (!url) return "";
    var u = ("" + url).trim();
    if (u.indexOf("//") === 0) {
      u = "https:" + u;
    } else if (u.indexOf("/") === 0) {
      u = MAIN_URL + u;
    }
    return u.replace(/\[/g, "%5B").replace(/\]/g, "%5D");
  } catch (e) {
    return url || "";
  }
}

function parseItemsFromHtml(html) {
  var items = [];
  try {
    if (!html) return items;

    var blocks = html.split(/class="[^"]*\bcol-lg-auto\b[^"]*"/);
    for (var i = 1; i < blocks.length; i++) {
      var block = blocks[i];

      var linkMatch = block.match(/<a\s+[^>]*href="([^"]+)"[^>]*class="[^"]*box[^"]*"/i) ||
                      block.match(/<a\s+[^>]*class="[^"]*box[^"]*"[^>]*href="([^"]+)"/i);
      if (!linkMatch) continue;
      var url = cleanUrl(linkMatch[1]);

      var titleMatch = block.match(/<h3\s+class="[^"]*entry-title[^"]*"[^>]*>([\s\S]*?)<\/h3>/i);
      if (!titleMatch) continue;
      var name = titleMatch[1].replace(/<[^>]+>/g, "").trim();

      var imgMatch = block.match(/<img[^>]*src="([^"]+)"/i);
      var posterUrl = imgMatch ? cleanUrl(imgMatch[1]) : undefined;

      items.push({
        name: name,
        url: url,
        posterUrl: posterUrl
      });
    }
  } catch (err) {}
  return items;
}

/**
 * 1. search(query)
 */
function search(query) {
  try {
    if (!query) return [];
    var searchUrl = MAIN_URL + "/search?q=" + encodeURIComponent(query);
    var html = httpGet(searchUrl);
    return parseItemsFromHtml(html);
  } catch (err) {
    return [];
  }
}

/**
 * 2. getMainPage()
 */
function getMainPage() {
  var result = [];
  try {
    var sections = [
      { name: "أحدث الأفلام", url: MAIN_URL + "/movies" },
      { name: "أحدث المسلسلات", url: MAIN_URL + "/series" }
    ];

    for (var i = 0; i < sections.length; i++) {
      try {
        var sec = sections[i];
        var html = httpGet(sec.url);
        var items = parseItemsFromHtml(html);
        if (items && items.length > 0) {
          result.push({
            name: sec.name,
            items: items
          });
        }
      } catch (e) {}
    }
  } catch (err) {}
  return result;
}

function parseEpisodesFromHtml(html) {
  var episodes = [];
  try {
    if (!html) return episodes;

    var epRegex = /<a\s+[^>]*href="([^"]*\/episode\/[^"]*)"[^>]*>([\s\S]*?)<\/a>/gi;
    var m;
    var seen = {};

    while ((m = epRegex.exec(html)) !== null) {
      try {
        var epUrl = cleanUrl(m[1]);
        if (seen[epUrl]) continue;
        seen[epUrl] = true;

        var inner = m[2];
        var numMatch = inner.match(/الحلقة\s*(\d+)/i) || epUrl.match(/الحلقة-(\d+)/i);
        var num = numMatch ? parseInt(numMatch[1], 10) : (episodes.length + 1);

        var titleMatch = inner.match(/<h2[^>]*>([\s\S]*?)<\/h2>/i) ||
                         inner.match(/<h3[^>]*>([\s\S]*?)<\/h3>/i);
        var epName = titleMatch ? titleMatch[1].replace(/<[^>]+>/g, "").trim() : ("الحلقة " + num);

        var imgMatch = inner.match(/<img[^>]*src="([^"]+)"/i);
        var epPoster = imgMatch ? cleanUrl(imgMatch[1]) : undefined;

        episodes.push({
          name: epName,
          url: epUrl,
          episode: num,
          posterUrl: epPoster
        });
      } catch (epErr) {}
    }
  } catch (err) {}
  return episodes;
}

/**
 * 3. load(url)
 */
function load(url) {
  try {
    var html = httpGet(url);
    if (!html) {
      return { name: "", url: url, year: null };
    }

    var titleMatch = html.match(/<h1[^>]*class="[^"]*entry-title[^"]*"[^>]*>([\s\S]*?)<\/h1>/i) ||
                     html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i);
    var name = titleMatch ? titleMatch[1].replace(/<[^>]+>/g, "").trim() : "";

    var posterMatch = html.match(/<img[^>]*src="([^"]*\/thumb\/260x380\/[^"]*)"/i) ||
                      html.match(/<img[^>]*src="([^"]*\/uploads\/[^"]*)"[^>]*class="[^"]*img-fluid[^"]*"/i) ||
                      html.match(/<div[^>]*class="[^"]*picture[^"]*"[\s\S]*?<img[^>]*src="([^"]+)"/i);
    var posterUrl = posterMatch ? cleanUrl(posterMatch[1]) : undefined;

    var plotMatch = html.match(/<div[^>]*class="[^"]*widget-body[^"]*"[^>]*>[\s\S]*?<p>([\s\S]*?)<\/p>/i) ||
                    html.match(/<p[^>]*class="[^"]*text-white[^"]*"[^>]*>([\s\S]*?)<\/p>/i);
    var plot = plotMatch ? plotMatch[1].replace(/<[^>]+>/g, "").replace(/&quot;/g, '"').trim() : undefined;

    var yearMatch = html.match(/سنة\s+الإنتاج\s*:\s*(\d{4})/i) ||
                    html.match(/\b(19\d\d|20\d\d)\b/);
    var year = yearMatch ? parseInt(yearMatch[1], 10) : null;

    var isSeries = (url.indexOf("/series/") !== -1);
    var episodes = isSeries ? parseEpisodesFromHtml(html) : undefined;

    return {
      name: name,
      url: url,
      posterUrl: posterUrl,
      plot: plot,
      year: year,
      type: isSeries ? "tvSeries" : "movie",
      episodes: episodes
    };
  } catch (err) {
    return { name: "", url: url, year: null };
  }
}

function extractStreams(html, prefix) {
  var links = [];
  var seen = {};

  try {
    var watchUrls = [];
    var watchRegex = /<a\s+[^>]*href="([^"]*\/watch\/[^"]*)"/gi;
    var m;

    while ((m = watchRegex.exec(html)) !== null) {
      var u = cleanUrl(m[1]);
      if (watchUrls.indexOf(u) === -1) {
        watchUrls.push(u);
      }
    }

    var maxServers = Math.min(watchUrls.length, 3);
    for (var i = 0; i < maxServers; i++) {
      try {
        var watchHtml = httpGet(watchUrls[i]);
        if (!watchHtml) continue;

        var sourceRegex = /<source\s+[^>]*src="([^"]+)"[^>]*>/gi;
        var sm;
        var found = 0;

        while ((sm = sourceRegex.exec(watchHtml)) !== null) {
          var sourceTag = sm[0];
          var rawSrc = sm[1];

          var isMp4 = /\.(mp4)(\?.*)?$/i.test(rawSrc) || sourceTag.indexOf("video/mp4") !== -1;
          var isHls = /\.(m3u8)(\?.*)?$/i.test(rawSrc) || sourceTag.indexOf("mpegurl") !== -1;
          if (!isMp4 && !isHls) continue;

          var videoUrl = cleanUrl(rawSrc);
          if (seen[videoUrl]) continue;
          seen[videoUrl] = true;

          var sizeMatch = sourceTag.match(/size="([^"]+)"/i);
          var quality = sizeMatch ? sizeMatch[1] + "p" : "HD";

          links.push({
            name: (prefix || "Akwam") + " - " + quality,
            url: videoUrl,
            headers: {
              "Referer": MAIN_URL + "/"
            }
          });
          found++;
        }

        if (found > 0 && links.length >= 2) break;
      } catch (errSrv) {}
    }
  } catch (err) {}

  return links;
}

/**
 * 4. loadLinks(url)
 */
function loadLinks(url) {
  try {
    var html = httpGet(url);
    if (!html) return [];

    if (url.indexOf("/series/") !== -1) {
      var eps = parseEpisodesFromHtml(html);
      if (eps.length > 0) {
        var epHtml = httpGet(eps[0].url);
        return extractStreams(epHtml, eps[0].name || "الحلقة 1");
      }
      return [];
    }

    return extractStreams(html, "Akwam");
  } catch (err) {
    return [];
  }
}
