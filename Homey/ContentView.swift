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
                        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard navigationAction.targetFrame == nil,
                  let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
            }
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
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
        }.frame(minWidth: 1000, minHeight: 700)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
