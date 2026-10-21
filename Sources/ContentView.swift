import SwiftUI
import WebKit
import UIKit
import AVFoundation

enum SuperAppTab: String, CaseIterable {
    case cockpit = "Cockpit"
    case farm = "Nông Trại"
    case report = "Báo Cáo"
    case crypto = "Crypto"
    case music = "Âm Nhạc"

    var icon: String {
        switch self {
        case .cockpit: return "square.grid.2x2.fill"
        case .farm: return "leaf.fill"
        case .report: return "chart.bar.xaxis"
        case .crypto: return "bitcoinsign.circle.fill"
        case .music: return "headphones"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: SuperAppTab = .cockpit
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var reloadToken = UUID()
    @State private var navCommandToken = UUID()
    @State private var pendingURL: URL = URL(string: "https://hub.buongloi.me")!
    @State private var pendingJS: String? = "if(window.hubSwitchMode) window.hubSwitchMode('bento');"
    @State private var estimatedProgress: Double = 0.0

    private let hubURL = URL(string: "https://hub.buongloi.me")!
    private let bgDark = Color(red: 0.047, green: 0.047, blue: 0.114)       // #0C0C1D
    private let emeraldAccent = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981
    private let purpleAccent = Color(red: 0.655, green: 0.545, blue: 0.980)  // #A78BFA

    var body: some View {
        ZStack(alignment: .top) {
            bgDark
                .ignoresSafeArea(.all)

            VStack(spacing: 0) {
                // Main WebView Viewport
                WebViewContainer(
                    initialURL: hubURL,
                    pendingURL: pendingURL,
                    pendingJS: pendingJS,
                    isLoading: $isLoading,
                    loadFailed: $loadFailed,
                    progress: $estimatedProgress,
                    selectedTab: $selectedTab,
                    reloadToken: reloadToken,
                    navCommandToken: navCommandToken
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Native iOS Super App Glassmorphic Bottom TabBar
                HStack(spacing: 0) {
                    ForEach(SuperAppTab.allCases, id: \.self) { tab in
                        Button(action: {
                            switchToTab(tab)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                                    .foregroundColor(selectedTab == tab ? emeraldAccent : Color(white: 0.58))
                                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                                Text(tab.rawValue)
                                    .font(.system(size: 10.5, weight: selectedTab == tab ? .bold : .medium, design: .rounded))
                                    .foregroundColor(selectedTab == tab ? .white : Color(white: 0.58))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 9)
                            .padding(.bottom, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .background(
                    Color(red: 0.055, green: 0.065, blue: 0.135)
                        .overlay(
                            Rectangle()
                                .fill(Color.white.opacity(0.09))
                                .frame(height: 0.6),
                            alignment: .top
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }

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

            // Initial Splash Screen
            if isLoading && estimatedProgress < 0.28 && selectedTab == .cockpit {
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
                            .frame(width: 74, height: 74)
                            .shadow(color: emeraldAccent.opacity(0.35), radius: 16, x: 0, y: 6)

                        Text("⚡")
                            .font(.system(size: 38))
                    }

                    Text("Buông Lơi Hub v3.0")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Live Cockpit • VPS Telemetry • GDrive Radio • Hay Day 2D")
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

                    Text("Không thể kết nối máy chủ")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Vui lòng kiểm tra lại kết nối Internet hoặc trạng thái hệ thống Buông Lơi.")
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
        .animation(.easeInOut(duration: 0.22), value: isLoading)
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }

    private func switchToTab(_ tab: SuperAppTab) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        selectedTab = tab
        loadFailed = false

        switch tab {
        case .cockpit:
            pendingURL = URL(string: "https://hub.buongloi.me")!
            pendingJS = "if(window.hubSwitchMode) window.hubSwitchMode('bento');"
        case .farm:
            pendingURL = URL(string: "https://hub.buongloi.me")!
            pendingJS = "if(window.hubSwitchMode) window.hubSwitchMode('2d');"
        case .report:
            pendingURL = URL(string: "https://report.buongloi.live")!
            pendingJS = nil
        case .crypto:
            pendingURL = URL(string: "https://bitcoin.buongloi.live")!
            pendingJS = nil
        case .music:
            pendingURL = URL(string: "https://music.buongloi.me")!
            pendingJS = nil
        }
        navCommandToken = UUID()
    }
}

// MARK: - WKWebView Wrapper
struct WebViewContainer: UIViewRepresentable {
    let initialURL: URL
    let pendingURL: URL
    let pendingJS: String?
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool
    @Binding var progress: Double
    @Binding var selectedTab: SuperAppTab
    let reloadToken: UUID
    let navCommandToken: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.applicationNameForUserAgent = "BuongLoiHubApp/3.0 (iOS)"

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

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 0.063, green: 0.725, blue: 0.506, alpha: 0.95)
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        context.coordinator.progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { wv, _ in
            DispatchQueue.main.async {
                self.progress = wv.estimatedProgress
            }
        }

        context.coordinator.webView = webView
        let request = URLRequest(url: initialURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 25)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            let target = webView.url ?? initialURL
            let request = URLRequest(url: target, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 25)
            webView.load(request)
        }

        if context.coordinator.lastNavCommandToken != navCommandToken {
            context.coordinator.lastNavCommandToken = navCommandToken
            let currentHost = webView.url?.host?.lowercased() ?? ""
            let targetHost = pendingURL.host?.lowercased() ?? ""

            if currentHost == targetHost, let js = pendingJS {
                webView.evaluateJavaScript(js, completionHandler: nil)
            } else {
                context.coordinator.deferredJS = pendingJS
                let request = URLRequest(url: pendingURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 25)
                webView.load(request)
            }
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebViewContainer
        weak var webView: WKWebView?
        var progressObservation: NSKeyValueObservation?
        var lastReloadToken: UUID?
        var lastNavCommandToken: UUID?
        var deferredJS: String?

        init(_ parent: WebViewContainer) {
            self.parent = parent
            self.lastReloadToken = parent.reloadToken
            self.lastNavCommandToken = parent.navCommandToken
        }

        deinit {
            progressObservation?.invalidate()
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
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
                webView.scrollView.refreshControl?.endRefreshing()
                if let js = self.deferredJS {
                    self.deferredJS = nil
                    webView.evaluateJavaScript(js, completionHandler: nil)
                }
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

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let targetURL = navigationAction.request.url else { return nil }
            let host = targetURL.host?.lowercased() ?? ""

            if host.contains("buongloi.live") || host.contains("buongloi.me") || host.contains("buongloi.dev") {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                DispatchQueue.main.async {
                    if host.contains("report.buongloi") { self.parent.selectedTab = .report }
                    else if host.contains("bitcoin.buongloi") { self.parent.selectedTab = .crypto }
                    else if host.contains("music.buongloi") { self.parent.selectedTab = .music }
                }
                webView.load(navigationAction.request)
            } else {
                UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
            }
            return nil
        }
    }
}
