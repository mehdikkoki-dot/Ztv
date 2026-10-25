import Foundation
import JavaScriptCore
import CommonCrypto

/// Native JavaScriptCore Execution Engine for CloudStream-like Extensions on iOS
public class JSRuntime {
    public static let shared = JSRuntime()
    private var context: JSContext
    
    private init() {
        self.context = JSContext()
        setupEnvironment()
    }
    
    private func setupEnvironment() {
        // Handle JS Exceptions
        context.exceptionHandler = { context, exception in
            if let exception = exception {
                print("⚡ [JSRuntime Error]: \(exception.toString() ?? "Unknown error")")
            }
        }
        
        // Polyfill console.log
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("📜 [JS Console]: \(message)")
        }
        context.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "_nativeLog" as NSString)
        context.evaluateScript("""
            var console = {
                log: function(msg) { _nativeLog(typeof msg === 'object' ? JSON.stringify(msg) : String(msg)); },
                error: function(msg) { _nativeLog('[ERROR] ' + (typeof msg === 'object' ? JSON.stringify(msg) : String(msg))); }
            };
        """)
        
        // Polyfill base64 decode/encode (atob / btoa)
        let atob: @convention(block) (String) -> String = { encoded in
            guard let data = Data(base64Encoded: encoded) else { return "" }
            return String(data: data, encoding: .utf8) ?? ""
        }
        let btoa: @convention(block) (String) -> String = { str in
            return Data(str.utf8).base64EncodedString()
        }
        context.setObject(unsafeBitCast(atob, to: AnyObject.self), forKeyedSubscript: "atob" as NSString)
        context.setObject(unsafeBitCast(btoa, to: AnyObject.self), forKeyedSubscript: "btoa" as NSString)
        
        // Native AES Decryptor Bridge (Used by video host extractors)
        let decryptAES: @convention(block) (String, String, String) -> String = { ciphertext, keyStr, ivStr in
            guard let cipherData = Data(base64Encoded: ciphertext),
                  let keyData = keyStr.data(using: .utf8),
                  let ivData = ivStr.data(using: .utf8) else {
                return ""
            }
            
            var decryptedData = Data(count: cipherData.count + kCCBlockSizeAES128)
            var numBytesDecrypted: size_t = 0
            
            let status = cipherData.withUnsafeBytes { cipherBytes in
                decryptedData.withUnsafeMutableBytes { decBytes in
                    keyData.withUnsafeBytes { keyBytes in
                        ivData.withUnsafeBytes { ivBytes in
                            CCCrypt(
                                CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, kCCKeySizeAES256,
                                ivBytes.baseAddress,
                                cipherBytes.baseAddress, cipherData.count,
                                decBytes.baseAddress, decBytes.count,
                                &numBytesDecrypted
                            )
                        }
                    }
                }
            }
            
            guard status == kCCSuccess else { return "" }
            decryptedData.removeSubrange(numBytesDecrypted..<decryptedData.count)
            return String(data: decryptedData, encoding: .utf8) ?? ""
        }
        context.setObject(unsafeBitCast(decryptAES, to: AnyObject.self), forKeyedSubscript: "_nativeDecryptAES" as NSString)
    }
    
    /// Synchronous / Async HTTP fetch bridge
    public func fetchUrl(urlString: String, headers: [String: String]? = nil) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /// Execute plugin script and return extracted streams as JSON
    public func executeProvider(scriptContent: String, functionName: String, argument: String) -> String? {
        context.evaluateScript(scriptContent)
        if let fn = context.objectForKeyedSubscript(functionName), !fn.isUndefined {
            let result = fn.call(withArguments: [argument])
            return result?.toString()
        }
        return nil
    }
}
