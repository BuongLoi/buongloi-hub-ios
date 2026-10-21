import SwiftUI
import WebKit
import UIKit

struct ContentView: View {
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var reloadToken = UUID()
    @State private var homeToken = UUID()
    @State private var estimatedProgress: Double = 0.0
    @State private var isOnSubApp = false

    let hubURL = URL(string: "https://hub.buongloi.me")!

    // Theme colors matching Buông Lơi Hub Bento Dark (#0C0C1D, #10B981, #A78BFA)
    private let bgDark = Color(red: 0.047, green: 0.047, blue: 0.114)       // #0C0C1D
    private let emeraldAccent = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981
    private let purpleAccent = Color(red: 0.655, green: 0.545, blue: 0.980)  // #A78BFA

    var body: some View {
        ZStack(alignment: .top) {
            bgDark
                .ignoresSafeArea(.all)

            WebViewContainer(
                url: hubURL,
                isLoading: $isLoading,
                loadFailed: $loadFailed,
                progress: $estimatedProgress,
                isOnSubApp: $isOnSubApp,
                reloadToken: reloadToken,
                homeToken: homeToken
            )
            .ignoresSafeArea(.all)

            // Top Loading Progress Bar
            if isLoading && estimatedProgress < 1.0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [emeraldAccent, purpleAccent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(estimatedProgress), height: 3)
                        .animation(.linear(duration: 0.2), value: estimatedProgress)
                }
                .frame(height: 3)
            }

            // Floating "Về Hub" Pill Button when browsing a child service inside Super App
            if isOnSubApp && !loadFailed {
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            homeToken = UUID()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Về Hub")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.06, green: 0.09, blue: 0.16).opacity(0.9))
                                    .overlay(
                                        Capsule()
                                            .stroke(emeraldAccent.opacity(0.75), lineWidth: 1.2)
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 4)
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 22)
                        Spacer()
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Initial Splash Screen
            if isLoading && estimatedProgress < 0.28 && !isOnSubApp {
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [emeraldAccent, purpleAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .shadow(color: emeraldAccent.opacity(0.35), radius: 16, x: 0, y: 6)

                        Text("⚡")
                            .font(.system(size: 36))
                    }

                    Text("Buông Lơi Hub")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Enterprise Command Center • Hay Day 2D")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.65))

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: emeraldAccent))
                        .scaleEffect(1.2)
                        .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgDark)
                .ignoresSafeArea(.all)
                .transition(.opacity)
            }

            // Offline / Connection Error View
            if loadFailed {
                VStack(spacing: 20) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 52))
                        .foregroundColor(emeraldAccent)

                    Text("Không thể kết nối Buông Lơi Hub")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Vui lòng kiểm tra lại kết nối Internet hoặc trạng thái máy chủ hub.buongloi.me.")
                        .font(.subheadline)
                        .foregroundColor(Color(white: 0.68))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        loadFailed = false
                        isLoading = true
                        reloadToken = UUID()
                    }) {
                        Label("Thử lại ngay", systemImage: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [emeraldAccent, purpleAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: emeraldAccent.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgDark)
                .ignoresSafeArea(.all)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLoading)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOnSubApp)
    }
}

// MARK: - WKWebView Wrapper
struct WebViewContainer: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool
    @Binding var progress: Double
    @Binding var isOnSubApp: Bool
    let reloadToken: UUID
    let homeToken: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.applicationNameForUserAgent = "BuongLoiHubApp/2.0 (iOS)"

        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "haptic")
        config.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true

        let darkColor = UIColor(red: 0.047, green: 0.047, blue: 0.114, alpha: 1.0)
        webView.backgroundColor = darkColor
        webView.isOpaque = false
        webView.scrollView.backgroundColor = darkColor
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        // Pull-to-Refresh with Emerald Accent spinner
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 0.95)
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        // Observe loading progress & current URL
        context.coordinator.progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { wv, _ in
            DispatchQueue.main.async {
                self.progress = wv.estimatedProgress
            }
        }

        context.coordinator.urlObservation = webView.observe(\.url, options: [.new]) { wv, _ in
            DispatchQueue.main.async {
                let host = wv.url?.host?.lowercased() ?? ""
                self.isOnSubApp = !host.isEmpty && host != "hub.buongloi.me"
            }
        }

        context.coordinator.webView = webView
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 25)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            let target = webView.url ?? url
            let request = URLRequest(url: target, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
            webView.load(request)
        }
        if context.coordinator.lastHomeToken != homeToken {
            context.coordinator.lastHomeToken = homeToken
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 25)
            webView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebViewContainer
        weak var webView: WKWebView?
        var progressObservation: NSKeyValueObservation?
        var urlObservation: NSKeyValueObservation?
        var lastReloadToken: UUID?
        var lastHomeToken: UUID?

        init(_ parent: WebViewContainer) {
            self.parent = parent
            self.lastReloadToken = parent.reloadToken
            self.lastHomeToken = parent.homeToken
        }

        deinit {
            progressObservation?.invalidate()
            urlObservation?.invalidate()
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            webView?.reload()
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "haptic" {
                let styleStr = (message.body as? String) ?? "light"
                let style: UIImpactFeedbackGenerator.FeedbackStyle
                switch styleStr {
                case "heavy": style = .heavy
                case "medium": style = .medium
                default: style = .light
                }
                let impact = UIImpactFeedbackGenerator(style: style)
                impact.impactOccurred()
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.loadFailed = false
            }
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
                let host = webView.url?.host?.lowercased() ?? ""
                self.parent.isOnSubApp = !host.isEmpty && host != "hub.buongloi.me"
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            DispatchQueue.main.async {
                self.parent.isLoading = false
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = true
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        // Handle target="_blank" & window.open links across the Buông Lơi Ecosystem
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let targetURL = navigationAction.request.url else { return nil }
            let host = targetURL.host?.lowercased() ?? ""

            if host.contains("buongloi.live") || host.contains("buongloi.me") || host.contains("buongloi.dev") {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                webView.load(navigationAction.request)
            } else {
                UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
            }
            return nil
        }
    }
}
