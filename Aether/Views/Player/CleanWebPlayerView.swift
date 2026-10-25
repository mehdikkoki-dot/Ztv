import SwiftUI
import WebKit

/// Sandboxed Ad-Blocked Web Player for Embed Servers (Fasel player, Dood, Streamtape, Akwam Web)
public struct CleanWebPlayerView: UIViewRepresentable {
    public let urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Anti-Popup & Ad-Block UserScript
        let adBlockScript = WKUserScript(
            source: """
            // Block popups and redirects
            window.open = function() { return null; };
            window.alert = function() {};
            window.confirm = function() { return true; };
            
            // Remove common ad overlays
            setInterval(function() {
                var adSelectors = ['iframe[src*="ads"]', 'div[class*="banner"]', 'div[id*="ad"]', 'div[class*="popup"]', 'a[target="_blank"]'];
                adSelectors.forEach(function(sel) {
                    var els = document.querySelectorAll(sel);
                    els.forEach(function(el) { if (el && el.parentElement && el.tagName !== 'VIDEO') el.remove(); });
                });
            }, 1000);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(adBlockScript)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            webView.load(request)
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}
