//
//  ContentView.swift
//  Homey
//
//  Created by Emile Nijssen on 25/12/2020.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            guard let url = navigationAction.request.url
            else {
                decisionHandler(.cancel)
                return
            }
            guard navigationAction.targetFrame != nil
            else {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            guard !url.pathComponents.isEmpty
            else {
                saveFile(from: url) { _ in
                    decisionHandler(.cancel)
                }
                return
            }
            decisionHandler(.allow)


        }

        /// Presents the save panel modal to store the file from the server on the disk.
        /// - Parameters:
        ///   - downloadURL: The url to download the file.
        ///   - completion: The block to call after the user closes the panel.
        private func saveFile(from downloadURL: URL, completion: @escaping (_ result: Result<Bool, Error>) -> ()) {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "insights.csv"
            savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))

            savePanel.begin { result in
                guard result == .OK, let url = savePanel.url
                else {
                    completion(.failure(
                        NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                    ))
                    return
                }

                URLSession.shared.dataTask(with: downloadURL) { data, response, err in
                    guard let data = data, err == nil
                    else {
                        completion(.failure(
                            NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to download the file"])
                        ))
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        debugPrint("Download http status is \(httpResponse.statusCode)")
                    }

                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try data.write(to: url, options: .atomic)
                            completion(.success(true))
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }.resume()
            }
        }
    }

    let view: WKWebView = WKWebView()

    var request: URLRequest {
        get {
            let url: URL = URL(string: "https://my.homey.app")!
            let request: URLRequest = URLRequest(url: url)
            return request
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        // Set User Agent
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        view.customUserAgent = "HomeyMacOS?version=\(version)&build=\(build)&macOS=\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
        
        view.load(request)
        return view
    }

    func updateNSView(_ view: WKWebView, context: Context) {
        view.navigationDelegate = context.coordinator
        view.load(request)
    }
}

struct ContentView: View {
    var body: some View {
        GeometryReader { g in
            ScrollView {
                WebView()
                    .frame(height: g.size.height)
            }.frame(height: g.size.height)
        }.frame(minWidth: 1100, minHeight: 780)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
