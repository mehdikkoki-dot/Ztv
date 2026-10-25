import Foundation
import JavaScriptCore

/// High-Performance Native JavaScriptCore Runner for CloudiOS Extensions (mehdikkoki-dot/T)
public class JSRuntime {
    public static let shared = JSRuntime()
    private var context: JSContext?
    
    private init() {
        setupEnvironment()
    }
    
    public func setupEnvironment() {
        guard let ctx = JSContext() else { return }
        self.context = ctx
        
        // Exception handler
        ctx.exceptionHandler = { context, exception in
            if let exc = exception {
                print("⚡ [JSRuntime Error]: \(exc.toString() ?? "")")
            }
        }
        
        // Console Polyfill
        let consoleLog: @convention(block) (String) -> Void = { msg in
            print("📜 [CloudiOS JS]: \(msg)")
        }
        ctx.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "_nativeLog" as NSString)
        ctx.evaluateScript("""
            var console = {
                log: function(msg) { _nativeLog(typeof msg === 'object' ? JSON.stringify(msg) : String(msg)); },
                error: function(msg) { _nativeLog('[ERROR] ' + (typeof msg === 'object' ? JSON.stringify(msg) : String(msg))); }
            };
        """)
        
        // Dynamic Host Function: httpGet(url, headers) with automatic redirect following
        let httpGet: @convention(block) (String, JSValue?) -> String = { urlString, headersVal in
            guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return ""
            }
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 12)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
            
            if let headersVal = headersVal, !headersVal.isUndefined, !headersVal.isNull, let dict = headersVal.toDictionary() as? [String: String] {
                for (k, v) in dict {
                    request.setValue(v, forHTTPHeaderField: k)
                }
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            var result = ""
            
            let task = URLSession.shared.dataTask(with: request) { data, response, _ in
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    result = str
                } else if let data = data, let str = String(data: data, encoding: .ascii) {
                    result = str
                }
                semaphore.signal()
            }
            task.resume()
            _ = semaphore.wait(timeout: .now() + 12)
            return result
        }
        ctx.setObject(unsafeBitCast(httpGet, to: AnyObject.self), forKeyedSubscript: "httpGet" as NSString)
        
        // Host Function: httpPost(url, body, headers)
        let httpPost: @convention(block) (String, String, JSValue?) -> String = { urlString, bodyString, headersVal in
            guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return ""
            }
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 12)
            request.httpMethod = "POST"
            request.httpBody = bodyString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            
            if let headersVal = headersVal, !headersVal.isUndefined, !headersVal.isNull, let dict = headersVal.toDictionary() as? [String: String] {
                for (k, v) in dict {
                    request.setValue(v, forHTTPHeaderField: k)
                }
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            var result = ""
            
            let task = URLSession.shared.dataTask(with: request) { data, _, _ in
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    result = str
                }
                semaphore.signal()
            }
            task.resume()
            _ = semaphore.wait(timeout: .now() + 12)
            return result
        }
        ctx.setObject(unsafeBitCast(httpPost, to: AnyObject.self), forKeyedSubscript: "httpPost" as NSString)
    }
    
    /// Loads a CloudiOS JavaScript plugin into the execution context
    public func loadPlugin(code: String) {
        setupEnvironment()
        context?.evaluateScript(code)
    }
    
    /// Calls `getMainPage()` on the loaded plugin
    public func getMainPage() -> [PluginSection] {
        guard let ctx = context, let fn = ctx.objectForKeyedSubscript("getMainPage"), !fn.isUndefined else {
            return []
        }
        let res = fn.call(withArguments: [])
        guard let jsonString = ctx.objectForKeyedSubscript("JSON")?.objectForKeyedSubscript("stringify")?.call(withArguments: [res as Any])?.toString(),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([PluginSection].self, from: data)) ?? []
    }
    
    /// Calls `search(query)` on the loaded plugin
    public func search(query: String) -> [PluginCardItem] {
        guard let ctx = context, let fn = ctx.objectForKeyedSubscript("search"), !fn.isUndefined else {
            return []
        }
        let res = fn.call(withArguments: [query])
        guard let jsonString = ctx.objectForKeyedSubscript("JSON")?.objectForKeyedSubscript("stringify")?.call(withArguments: [res as Any])?.toString(),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([PluginCardItem].self, from: data)) ?? []
    }
    
    /// Calls `load(url)` to get details and episodes
    public func load(url: String) -> PluginMediaDetail? {
        guard let ctx = context, let fn = ctx.objectForKeyedSubscript("load"), !fn.isUndefined else {
            return nil
        }
        let res = fn.call(withArguments: [url])
        guard let jsonString = ctx.objectForKeyedSubscript("JSON")?.objectForKeyedSubscript("stringify")?.call(withArguments: [res as Any])?.toString(),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(PluginMediaDetail.self, from: data)
    }
    
    /// Calls `loadLinks(url)` to get stream links
    public func loadLinks(url: String) -> [PluginStreamLink] {
        guard let ctx = context, let fn = ctx.objectForKeyedSubscript("loadLinks"), !fn.isUndefined else {
            return []
        }
        let res = fn.call(withArguments: [url])
        guard let jsonString = ctx.objectForKeyedSubscript("JSON")?.objectForKeyedSubscript("stringify")?.call(withArguments: [res as Any])?.toString(),
              let data = jsonString.data(using: .utf8) else {
            return []
        }
        return (try? JSONDecoder().decode([PluginStreamLink].self, from: data)) ?? []
    }
}
