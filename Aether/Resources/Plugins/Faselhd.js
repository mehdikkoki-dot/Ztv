/**
 * FASELHD CloudiOS JavaScript plugin
 * ES5 / JavaScriptCore
 * Generated from re-3arabi source: re-3arabi-main/Faselhd/src/main/kotlin/com/faselhd/Faselhd.kt
 * NOTE: CSS selectors and stream extraction require live-site validation.
 */
var MAIN_URL = "https://web31312x.faselhdx.bid";
var PLUGIN_NAME = "FASELHD";
var CARD_SELECTOR = ".poster img";
var MAIN_SECTIONS = [];

function cleanUrl(url) {
  try {
    if (!url) return "";
    var u = ("" + url).replace(/^\s+|\s+$/g, "");
    if (u.indexOf("//") === 0) u = "https:" + u;
    else if (u.charAt(0) === "/") u = MAIN_URL.replace(/\/$/, "") + u;
    return u.replace(/&amp;/g, "&").replace(/\[/g, "%5B").replace(/\]/g, "%5D");
  } catch (e) { return url || ""; }
}

function decodeText(s) {
  if (!s) return "";
  return ("" + s).replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;|&#160;/gi, " ").replace(/&quot;/gi, '\"')
    .replace(/&#39;|&apos;/gi, "'").replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<").replace(/&gt;/gi, ">")
    .replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "");
}

function attr(tag, key) {
  var re = new RegExp("\\b" + key + "\\s*=\\s*([\"'])([\\s\\S]*?)\\1", "i");
  var m = (tag || "").match(re); return m ? m[2] : "";
}

function uniquePush(out, seen, item) {
  if (!item || !item.url || seen[item.url]) return;
  seen[item.url] = true; out.push(item);
}

function parseItemsFromHtml(html) {
  var items = [], seen = {};
  if (!html) return items;
  try {
    /* Use site-derived card classes first, then conservative anchor fallback. */
    var blocks = html.split(/<\/(?:article|div|li)>/i);
    for (var i = 0; i < blocks.length; i++) {
      var b = blocks[i];
      if (b.indexOf('<a') < 0) continue;
      var am = b.match(/<a\b[^>]*href\s*=\s*([\"'])(.*?)\1[^>]*>/i);
      if (!am) continue;
      var href = cleanUrl(am[2]);
      if (!/^https?:\/\//i.test(href) || href === MAIN_URL || /javascript:|#/.test(href)) continue;
      var tm = b.match(/<(?:h[1-6]|title)[^>]*>([\s\S]*?)<\/(?:h[1-6]|title)>/i);
      var title = tm ? decodeText(tm[1]) : decodeText(attr(am[0], 'title'));
      if (!title) { var imgt = b.match(/<img\b[^>]*>/i); title = imgt ? decodeText(attr(imgt[0], 'alt')) : ''; }
      if (!title || title.length > 180) continue;
      var imgm = b.match(/<img\b[^>]*>/i);
      var poster = imgm ? (attr(imgm[0], 'data-src') || attr(imgm[0], 'data-lazy-src') || attr(imgm[0], 'src') || attr(imgm[0], 'data-original')) : '';
      poster = poster ? cleanUrl(poster) : undefined;
      if (seen[href]) continue; seen[href] = true;
      items.push({ name: title, url: href, posterUrl: poster });
    }
  } catch (e) {}
  return items;
}

function search(query) {
  try {
    if (!query) return [];
    var url = MAIN_URL + '/?s=' + encodeURIComponent(query);
    var html = httpGet(url);
    var items = parseItemsFromHtml(html);
    if (items.length) return items;
    html = httpGet(MAIN_URL + '/search?q=' + encodeURIComponent(query));
    return parseItemsFromHtml(html);
  } catch (e) { return []; }
}

function getMainPage() {
  var result = [];
  try {
    for (var i = 0; i < MAIN_SECTIONS.length; i++) {
      try { var sec = MAIN_SECTIONS[i]; var items = parseItemsFromHtml(httpGet(sec.url));
        if (items.length) result.push({ name: sec.name, items: items });
      } catch (e) {}
    }
    if (!result.length) { var homeItems = parseItemsFromHtml(httpGet(MAIN_URL));
      if (homeItems.length) result.push({ name: 'الرئيسية', items: homeItems }); }
  } catch (e) {}
  return result;
}

function parseEpisodesFromHtml(html) {
  var episodes = [], seen = {};
  if (!html) return episodes;
  try {
    var re = /<a\b[^>]*href\s*=\s*([\"'])(.*?)\1[^>]*>([\s\S]*?)<\/a>/gi, m;
    while ((m = re.exec(html)) !== null) {
      var href = cleanUrl(m[2]);
      if (!/episode|watch|الحلقة|\/ep\b|\/episodes?\//i.test(href + ' ' + m[3]) || seen[href]) continue;
      var txt = decodeText(m[3]); if (!txt) continue;
      var nm = txt.match(/(?:الحلقة|episode|ep)\s*[-:#]?\s*(\d+)/i);
      var num = nm ? parseInt(nm[1], 10) : episodes.length + 1;
      var im = m[3].match(/<img\b[^>]*>/i); var poster = im ? (attr(im[0], 'data-src') || attr(im[0], 'src')) : '';
      seen[href] = true; episodes.push({ name: txt.length < 90 ? txt : ('الحلقة ' + num), url: href, episode: num, posterUrl: poster ? cleanUrl(poster) : undefined });
    }
  } catch (e) {}
  return episodes;
}

function load(url) {
  try {
    var html = httpGet(url); if (!html) return { name: '', url: url, year: null };
    var h = html.match(/<h1\b[^>]*>([\s\S]*?)<\/h1>/i) || html.match(/<meta[^>]+property=[\"']og:title[\"'][^>]+content=[\"']([^\"']+)/i);
    var name = h ? decodeText(h[1]) : '';
    var pm = html.match(/<meta[^>]+property=[\"']og:image[\"'][^>]+content=[\"']([^\"']+)/i) || html.match(/<img\b[^>]*class=[\"'][^\"']*(?:poster|cover|thumbnail)[^\"']*[\"'][^>]*>/i) || html.match(/<img\b[^>]*>/i);
    var poster = ''; if (pm) poster = pm[1] && pm[1].indexOf('<') < 0 ? pm[1] : (attr(pm[0], 'data-src') || attr(pm[0], 'src'));
    var plotm = html.match(/<(?:p|div)[^>]*(?:class|id)=[\"'][^\"']*(?:story|plot|description|summary|StoryArea)[^\"']*[\"'][^>]*>([\s\S]*?)<\/(?:p|div)>/i);
    var yearm = html.match(/\b(19\d{2}|20\d{2})\b/);
    var isSeries = /series|مسلسل|anime|season|الموسم/i.test(url + ' ' + name) || /allepcont|EpisodesList|episode-list|seasonDiv/i.test(html);
    return { name: name, url: url, posterUrl: poster ? cleanUrl(poster) : undefined, plot: plotm ? decodeText(plotm[1]) : undefined, year: yearm ? parseInt(yearm[1], 10) : null, type: isSeries ? 'tvSeries' : 'movie', episodes: isSeries ? parseEpisodesFromHtml(html) : undefined };
  } catch (e) { return { name: '', url: url, year: null }; }
}

function extractStreams(html, prefix) {
  var links = [], seen = {}; if (!html) return links;
  try {
    var candidates = [], re = /(?:<source\b[^>]*src\s*=\s*|<iframe\b[^>]*src\s*=\s*|data-(?:src|url|video)\s*=\s*|file\s*:\s*)[\"']([^\"']+)[\"']/gi, m;
    while ((m = re.exec(html)) !== null) {
      var u = m[1].replace(/\\\\//g, '/');
      if (!/^https?:|^\/\//i.test(u) || /google|facebook|twitter|doubleclick/i.test(u)) continue;
      if (!/\.(?:mp4|m3u8|mpd)(?:[?#].*)?$/i.test(u) && !/embed|player|stream|video|watch/i.test(u)) continue;
      u = cleanUrl(u); if (!seen[u]) { seen[u] = true; candidates.push(u); }
    }
    for (var i = 0; i < candidates.length; i++) {
      var u = candidates[i];
      links.push({ name: (prefix || PLUGIN_NAME) + ' - ' + (/\.m3u8/i.test(u) ? 'HLS' : /\.mp4/i.test(u) ? 'MP4' : 'Server ' + (i + 1)), url: u, headers: { Referer: urlOrigin(u) } });
    }
  } catch (e) {}
  return links;
}
function urlOrigin(url) { var m = (url || '').match(/^(https?:\/\/[^\/]+)/i); return m ? m[1] + '/' : MAIN_URL + '/'; }

function loadLinks(url) {
  try {
    var html = httpGet(url); if (!html) return [];
    var links = extractStreams(html, PLUGIN_NAME);
    if (links.length) return links;
    var eps = parseEpisodesFromHtml(html);
    if (eps.length) return extractStreams(httpGet(eps[0].url), eps[0].name);
    var embeds = [], re = /<iframe\b[^>]*src\s*=\s*([\"'])(.*?)\1/gi, m;
    while ((m = re.exec(html)) !== null) { var e = cleanUrl(m[2]); if (/^https?:/i.test(e) && embeds.indexOf(e) < 0) embeds.push(e); }
    for (var i = 0; i < embeds.length; i++) { try { var found = extractStreams(httpGet(embeds[i]), PLUGIN_NAME); links = links.concat(found); } catch (e) {} }
    return links;
  } catch (e) { return []; }
}
