import SwiftUI
import WebKit

/// Sandboxed Ad-Blocked Clean Player for Embed Video Streams
public struct CleanWebPlayerView: UIViewRepresentable {
    public let urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Anti-Popup, Ad-Block & Full-Screen Video UserScript
        let cleanScript = WKUserScript(
            source: """
            // 1. Prevent popups, alerts and new tabs
            window.open = function() { return null; };
            window.alert = function() {};
            window.confirm = function() { return true; };
            
            // 2. Continuous ad element stripper
            setInterval(function() {
                var adSelectors = [
                    'iframe[src*="ads"]', 'div[class*="banner"]', 'div[id*="ad"]',
                    'div[class*="popup"]', 'a[target="_blank"]', '.ad-box',
                    '#overlay-ad', '.video-ad-overlay'
                ];
                adSelectors.forEach(function(sel) {
                    var els = document.querySelectorAll(sel);
                    els.forEach(function(el) {
                        if (el && el.parentElement && el.tagName !== 'VIDEO') {
                            el.remove();
                        }
                    });
                });
                
                // Maximize video to viewport
                var videos = document.getElementsByTagName('video');
                for (var i = 0; i < videos.length; i++) {
                    videos[i].style.width = '100vw';
                    videos[i].style.height = '100vh';
                    videos[i].style.objectFit = 'contain';
                    videos[i].setAttribute('playsinline', '');
                    videos[i].setAttribute('webkit-playsinline', '');
                }
            }, 800);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        config.userContentController.addUserScript(cleanScript)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            webView.load(request)
        }
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Block navigation to new windows or app store links
            if navigationAction.targetFrame == nil {
                decisionHandler(.cancel)
                return
            }
            if let url = navigationAction.request.url?.absoluteString,
               url.contains("itunes.apple.com") || url.contains("apps.apple.com") || url.contains("adclick") {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
