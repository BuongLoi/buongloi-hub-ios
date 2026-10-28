import SwiftUI
import WebKit
import UIKit
import AVFoundation

// MARK: - Super App Tabs (v4.0 Hybrid Native + Persistent WebViews)
enum SuperAppTab: String, CaseIterable {
    case cockpit = "Cockpit"
    case report  = "Báo Cáo"
    case crypto  = "Crypto"
    case news    = "Tin Tức"
    case farm    = "Nông Trại"

    var icon: String {
        switch self {
        case .cockpit: return "bolt.shield.fill"
        case .report:  return "chart.bar.doc.horizontal.fill"
        case .crypto:  return "bitcoinsign.circle.fill"
        case .news:    return "newspaper.fill"
        case .farm:    return "leaf.fill"
        }
    }

    var webURL: URL? {
        switch self {
        case .cockpit: return nil
        case .report:  return URL(string: "https://report.buongloi.live")
        case .crypto:  return URL(string: "https://bitcoin.buongloi.live")
        case .news:    return URL(string: "https://news.buongloi.live")
        case .farm:    return URL(string: "https://hub.buongloi.me/?mode=2d&embed=ios")
        }
    }
}

// MARK: - API Models for /api/live-hub
struct LiveHubResponse: Codable {
    let updated_at: Double?
    let vps: VpsTelemetry?
    let bitcoin: CryptoTelemetry?
    let weather: WeatherTelemetry?
    let news: NewsTelemetry?
    let giveaway: GiveawayTelemetry?
    let music: MusicTelemetry?
    let health: HealthTelemetry?
}

struct VpsTelemetry: Codable {
    let cpu_pct: Double?
    let ram_used_gb: Double?
    let ram_total_gb: Double?
    let ram_pct: Double?
    let swap_used_mb: Double?
    let swap_total_mb: Double?
    let swap_pct: Double?
    let disk_used_gb: String?
    let disk_total_gb: String?
    let disk_pct: Int?
    let uptime_str: String?
    let load_avg: String?
    let services: [SystemdServiceItem]?
}

struct SystemdServiceItem: Codable, Identifiable {
    var id: String { unit }
    let unit: String
    let label: String
    let active: Bool
    let manager: String?
    let group: String?
}

struct AuthResponse: Codable {
    let ok: Bool?
    let authenticated: Bool?
    let token: String?
    let username: String?
    let message: String?
    let error: String?
}

struct OpsActionResponse: Codable {
    let ok: Bool?
    let unit: String?
    let label: String?
    let active: Bool?
    let message: String?
    let error: String?
}

struct OpsLogsResponse: Codable {
    let ok: Bool?
    let unit: String?
    let label: String?
    let manager: String?
    let logs: String?
    let error: String?
}

struct CryptoTelemetry: Codable {
    let price: Double?
    let change_24h_pct: Double?
    let high_24h: Double?
    let low_24h: Double?
    let rsi_14: Int?
    let eth_price: Double?
    let eth_change_pct: Double?
    let sol_price: Double?
    let sol_change_pct: Double?
    let fear_greed_val: Int?
    let fear_greed_label: String?
    let sparkline: [Double]?
}

struct WeatherTelemetry: Codable {
    let city: String?
    let temp: Double?
    let feels_like: Double?
    let humidity: Int?
    let wind_speed: Double?
    let description: String?
}

struct NewsTelemetry: Codable {
    let total_articles: Int?
    let headlines: [HeadlineItem]?
}

struct HeadlineItem: Codable, Identifiable {
    var id: String { (title ?? "") + (url ?? "") }
    let title: String?
    let source: String?
    let category: String?
    let summary: String?
    let url: String?
}

struct GiveawayTelemetry: Codable {
    let total: Int?
    let recent: [GiveawayItem]?
}

struct GiveawayItem: Codable, Identifiable {
    var id: String { (title ?? "") + (url ?? "") }
    let title: String?
    let source: String?
    let url: String?
}

struct MusicTelemetry: Codable {
    let total_tracks: Int?
    let tracks: [MusicTrackItem]?
}

struct MusicTrackItem: Codable, Identifiable {
    var id: Int { idx }
    let idx: Int
    let title: String
    let artist: String
}

struct HealthTelemetry: Codable {
    let online_count: Int?
    let total_count: Int?
    let avg_latency_ms: Int?
    let results: [String: HealthPingItem]?
}

struct HealthPingItem: Codable {
    let ok: Bool?
    let latency_ms: Int?
}

// MARK: - 14 Ecosystem App Metadata for Native Launchpad
struct EcosystemApp: Identifiable {
    let id: String
    let name: String
    let role: String
    let category: String
    let sfSymbol: String
    let hexColor: Color
    let urlString: String
    let healthKey: String
}

let ECOSYSTEM_APPS: [EcosystemApp] = [
    EcosystemApp(id: "bitcoin", name: "Bitcoin Dashboard", role: "On-Chain & Scalping", category: "Crypto", sfSymbol: "bitcoinsign.circle.fill", hexColor: Color(red: 0.98, green: 0.75, blue: 0.14), urlString: "https://bitcoin.buongloi.live", healthKey: "https://bitcoin.buongloi.live"),
    EcosystemApp(id: "report", name: "Report Hub", role: "P&L & Sales 3GB", category: "Analytics", sfSymbol: "chart.bar.xaxis", hexColor: Color(red: 0.94, green: 0.27, blue: 0.27), urlString: "https://report.buongloi.live", healthKey: "https://report.buongloi.live"),
    EcosystemApp(id: "news", name: "News Digest AI", role: "Điểm Tin AI & TTS", category: "AI", sfSymbol: "newspaper.fill", hexColor: Color(red: 0.20, green: 0.83, blue: 0.60), urlString: "https://news.buongloi.live", healthKey: "https://news.buongloi.live"),
    EcosystemApp(id: "weather", name: "Thiên Tượng", role: "Khí Tượng & Radar", category: "Utility", sfSymbol: "cloud.sun.rain.fill", hexColor: Color(red: 0.22, green: 0.74, blue: 0.97), urlString: "https://weather.buongloi.me", healthKey: "https://weather.buongloi.me/api/health"),
    EcosystemApp(id: "music", name: "Buông Lơi Music", role: "GDrive Audio 30GB", category: "Media", sfSymbol: "headphones", hexColor: Color(red: 0.11, green: 0.73, blue: 0.33), urlString: "https://music.buongloi.me", healthKey: "https://music.buongloi.me"),
    EcosystemApp(id: "keyin", name: "KeyIn Master Data", role: "Đối Soát 170k+ SKU", category: "Analytics", sfSymbol: "cylinder.split.1x2.fill", hexColor: Color(red: 0.38, green: 0.65, blue: 0.98), urlString: "https://keyin.buongloi.dev", healthKey: "https://keyin.buongloi.dev"),
    EcosystemApp(id: "giveaway", name: "Giveaway Bot", role: "Săn Kèo Bản Quyền", category: "Tools", sfSymbol: "gift.fill", hexColor: Color(red: 0.96, green: 0.25, blue: 0.37), urlString: "https://giveaway.buongloi.live", healthKey: "https://giveaway.buongloi.live"),
    EcosystemApp(id: "tickit", name: "TickIt Countdown", role: "Cozy Lofi Timer", category: "Utility", sfSymbol: "timer", hexColor: Color(red: 0.75, green: 0.52, blue: 0.99), urlString: "https://tickit.buongloi.live", healthKey: "https://tickit.buongloi.live"),
    EcosystemApp(id: "pptx", name: "PPTX Generator", role: "Tự Động Hóa Slide", category: "Tools", sfSymbol: "rectangle.stack.badge.play.fill", hexColor: Color(red: 0.65, green: 0.55, blue: 0.98), urlString: "https://pptx.buongloi.live", healthKey: "https://pptx.buongloi.live/api/health"),
    EcosystemApp(id: "price", name: "Price Checker", role: "Tra Cứu Giá POS", category: "Retail", sfSymbol: "tag.fill", hexColor: Color(red: 0.98, green: 0.44, blue: 0.40), urlString: "https://pptx.buongloi.live/price-checker", healthKey: "https://pptx.buongloi.live/api/health"),
    EcosystemApp(id: "barcode", name: "Barcode Overlay", role: "In Tem Nhãn Giá", category: "Retail", sfSymbol: "barcode.viewfinder", hexColor: Color(red: 0.92, green: 0.35, blue: 0.05), urlString: "https://pptx.buongloi.live/barcode", healthKey: "https://pptx.buongloi.live/api/health"),
    EcosystemApp(id: "warranty", name: "Warranty Manager", role: "Quản Lý Bảo Hành", category: "Retail", sfSymbol: "checkmark.shield.fill", hexColor: Color(red: 0.85, green: 0.47, blue: 0.02), urlString: "https://pptx.buongloi.live/warranty", healthKey: "https://pptx.buongloi.live/api/health"),
    EcosystemApp(id: "gmail", name: "Gmail Manager", role: "Điều Phối Hộp Thư", category: "Tools", sfSymbol: "envelope.fill", hexColor: Color(red: 0.01, green: 0.52, blue: 0.78), urlString: "https://gmail.buongloi.live", healthKey: "https://gmail.buongloi.live"),
    EcosystemApp(id: "reels", name: "Reels Audio Bot", role: "Bot Trích Xuất MP3", category: "Media", sfSymbol: "waveform.circle.fill", hexColor: Color(red: 0.05, green: 0.58, blue: 0.53), urlString: "https://t.me/ReelsAudioBot", healthKey: "https://music.buongloi.me")
]

struct SheetWebTarget: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

// MARK: - Live Hub ViewModel & Native AVPlayer Cloud Streamer
@MainActor
final class LiveHubViewModel: ObservableObject {
    @Published var data: LiveHubResponse?
    @Published var isSyncing: Bool = false
    @Published var feedTab: Int = 0 // 0 = News, 1 = Giveaways
    @Published var isPlayingAudio: Bool = false
    @Published var currentTrackIndex: Int = 0

    // Admin Auth & DevOps State
    @Published var authToken: String = UserDefaults.standard.string(forKey: "hub_admin_token") ?? ""
    @Published var adminUsername: String = UserDefaults.standard.string(forKey: "hub_admin_user") ?? "admin"
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    @Published var showAuthSheet: Bool = false
    @Published var selectedOpsService: SystemdServiceItem?
    var pendingOpsService: SystemdServiceItem?

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    func verifyAdminToken() async {
        isCheckingAuth = true
        defer { isCheckingAuth = false }
        guard !authToken.isEmpty, let url = URL(string: "https://hub.buongloi.me/api/auth/verify") else {
            isAuthenticated = false
            return
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        do {
            let (raw, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 200,
               let decoded = try? JSONDecoder().decode(AuthResponse.self, from: raw),
               decoded.authenticated == true {
                isAuthenticated = true
                if let u = decoded.username { adminUsername = u }
                return
            }
        } catch {}
        isAuthenticated = false
    }

    func selectServiceForOps(_ svc: SystemdServiceItem) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if isAuthenticated {
            selectedOpsService = svc
        } else {
            pendingOpsService = svc
            showAuthSheet = true
        }
    }

    func loginAdmin(username: String, password: String) async -> (Bool, String) {
        guard let url = URL(string: "https://hub.buongloi.me/api/auth/login") else {
            return (false, "URL không hợp lệ")
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["username": username, "password": password]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (raw, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode(AuthResponse.self, from: raw)
            if decoded.ok == true, let tok = decoded.token {
                authToken = tok
                adminUsername = decoded.username ?? username
                isAuthenticated = true
                UserDefaults.standard.set(tok, forKey: "hub_admin_token")
                UserDefaults.standard.set(adminUsername, forKey: "hub_admin_user")
                return (true, "Đăng nhập thành công!")
            } else {
                return (false, decoded.error ?? "Sai tài khoản hoặc mật khẩu!")
            }
        } catch {
            return (false, "Lỗi kết nối: \(error.localizedDescription)")
        }
    }

    func changeAdminPassword(currentPassword: String, newUsername: String, newPassword: String) async -> (Bool, String) {
        guard let url = URL(string: "https://hub.buongloi.me/api/auth/change-password") else {
            return (false, "URL không hợp lệ")
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let body: [String: String] = [
            "current_password": currentPassword,
            "new_username": newUsername,
            "new_password": newPassword
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (raw, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode(AuthResponse.self, from: raw)
            if decoded.ok == true, let tok = decoded.token {
                authToken = tok
                adminUsername = decoded.username ?? newUsername
                UserDefaults.standard.set(tok, forKey: "hub_admin_token")
                UserDefaults.standard.set(adminUsername, forKey: "hub_admin_user")
                return (true, decoded.message ?? "Đã đổi mật khẩu thành công!")
            } else {
                return (false, decoded.error ?? "Đổi mật khẩu thất bại!")
            }
        } catch {
            return (false, "Lỗi kết nối: \(error.localizedDescription)")
        }
    }

    func logoutAdmin() {
        player?.pause()
        isPlayingAudio = false
        authToken = ""
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "hub_admin_token")
    }

    func restartService(unit: String) async -> (Bool, String) {
        guard let url = URL(string: "https://hub.buongloi.me/api/ops/restart") else {
            return (false, "URL không hợp lệ")
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["unit": unit])

        do {
            let (raw, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
                logoutAdmin()
                return (false, "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.")
            }
            let decoded = try JSONDecoder().decode(OpsActionResponse.self, from: raw)
            if decoded.ok == true {
                let isGatewaySelf = (unit == "all-gateways" || unit == "cloudflared" || unit == "nginx")
                if isGatewaySelf {
                    Task {
                        try? await Task.sleep(nanoseconds: 3_800_000_000)
                        await fetchLiveHub(force: true)
                    }
                } else {
                    await fetchLiveHub(force: true)
                }
                return (true, decoded.message ?? "Đã khởi động lại thành công!")
            } else {
                return (false, decoded.error ?? "Restart thất bại!")
            }
        } catch {
            if unit == "all-gateways" || unit == "cloudflared" || unit == "nginx" {
                Task {
                    try? await Task.sleep(nanoseconds: 3_800_000_000)
                    await fetchLiveHub(force: true)
                }
                return (true, "Đã khởi động lại Gateway thành công! Đường truyền Cloudflare Tunnel vừa tái kết nối.")
            }
            return (false, "Lỗi kết nối: \(error.localizedDescription)")
        }
    }

    func fetchServiceLogs(unit: String) async -> String {
        if unit == "all-gateways" {
            return "Chế độ Khởi động lại toàn bộ Gateway:\n• Nginx Reverse Proxy (nginx.service)\n• Cloudflare Tunnel (cloudflared.service)\n• Hermes Agent Gateway (hermes-gateway.service)\n\nNhấn nút '🔄 Khởi Động Lại Dịch Vụ (Restart)' phía trên để thực thi ngay."
        }
        guard let encoded = unit.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://hub.buongloi.me/api/ops/logs?unit=\(encoded)&lines=65") else {
            return "URL không hợp lệ."
        }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        do {
            let (raw, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 401 {
                logoutAdmin()
                return "⚠️ Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."
            }
            let decoded = try JSONDecoder().decode(OpsLogsResponse.self, from: raw)
            if decoded.ok == true {
                return decoded.logs ?? "Không có dữ liệu log."
            } else {
                return "⚠️ \(decoded.error ?? "Không thể tải log.")"
            }
        } catch {
            return "⚠️ Lỗi kết nối: \(error.localizedDescription)"
        }
    }

    func fetchLiveHub(force: Bool = false) async {
        guard isAuthenticated, !authToken.isEmpty else { return }
        isSyncing = true
        defer { isSyncing = false }

        let urlStr = force ? "https://hub.buongloi.me/api/live-hub?force=1" : "https://hub.buongloi.me/api/live-hub"
        guard let url = URL(string: urlStr) else { return }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 18)
        req.setValue("BuongLoiHubNative/4.2 (iOS)", forHTTPHeaderField: "User-Agent")
        req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let (raw, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse {
                if http.statusCode == 401 {
                    logoutAdmin()
                    return
                }
                if http.statusCode == 200 {
                    let decoded = try JSONDecoder().decode(LiveHubResponse.self, from: raw)
                    self.data = decoded
                }
            }
        } catch {
            // Keep existing cached data if offline
        }
    }

    var tracks: [MusicTrackItem] {
        data?.music?.tracks ?? []
    }

    var currentTrackTitle: String {
        guard !tracks.isEmpty, currentTrackIndex >= 0, currentTrackIndex < tracks.count else {
            return "Buông Lơi GDrive Studio"
        }
        return tracks[currentTrackIndex].title
    }

    var currentTrackArtist: String {
        guard !tracks.isEmpty, currentTrackIndex >= 0, currentTrackIndex < tracks.count else {
            return "Nhấn ▶️ để stream nhạc từ Google Drive"
        }
        return "\(tracks[currentTrackIndex].artist) · Cloud Stream"
    }

    func togglePlay() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if isPlayingAudio {
            player?.pause()
            isPlayingAudio = false
        } else {
            if player != nil {
                player?.play()
                isPlayingAudio = true
            } else {
                let startIdx = tracks.isEmpty ? 0 : Int.random(in: 0..<tracks.count)
                playTrack(at: startIdx)
            }
        }
    }

    func playTrack(at index: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let list = tracks
        let safeIdx = list.isEmpty ? 0 : ((index % list.count) + list.count) % list.count
        currentTrackIndex = safeIdx
        let streamIdx = list.isEmpty ? 0 : list[safeIdx].idx
        let encodedTok = authToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let streamURL = URL(string: "https://hub.buongloi.me/api/music/stream?idx=\(streamIdx)&token=\(encodedTok)") else { return }

        if let oldObs = endObserver {
            NotificationCenter.default.removeObserver(oldObs)
        }

        let item = AVPlayerItem(url: streamURL)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.playTrack(at: self.currentTrackIndex + 1)
            }
        }

        player?.play()
        isPlayingAudio = true
    }

    func nextTrack() {
        playTrack(at: currentTrackIndex + 1)
    }

    func prevTrack() {
        playTrack(at: currentTrackIndex - 1)
    }
}

// MARK: - Main Super App View
struct ContentView: View {
    @StateObject private var vm = LiveHubViewModel()
    @State private var selectedTab: SuperAppTab = .cockpit
    @State private var activeSheet: SheetWebTarget?

    private let bgDark = Color(red: 0.035, green: 0.043, blue: 0.098)       // #090B19
    private let cardBg = Color(red: 0.082, green: 0.098, blue: 0.196)       // #151932
    private let emeraldAccent = Color(red: 0.204, green: 0.827, blue: 0.600) // #34D399
    private let amberAccent = Color(red: 0.984, green: 0.749, blue: 0.141)   // #FBBF24

    var body: some View {
        ZStack(alignment: .bottom) {
            bgDark.ignoresSafeArea()

            if vm.isAuthenticated {
                VStack(spacing: 0) {
                    // Viewport Area: Either Pure Native SwiftUI Cockpit OR Nông Trại 2D WebView
                    ZStack {
                        if selectedTab == .farm {
                            PersistentWebDeck(selectedTab: .farm, authToken: vm.authToken)
                                .transition(.opacity)
                        }

                        if selectedTab == .cockpit {
                            NativeCockpitScrollView(
                                vm: vm,
                                selectedTab: $selectedTab,
                                activeSheet: $activeSheet
                            )
                            .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                FullScreenLoginGateView(vm: vm)
                    .transition(.opacity)
            }
        }
        .sheet(item: $activeSheet) { item in
            InAppBrowserSheet(target: item)
        }
        .sheet(isPresented: $vm.showAuthSheet) {
            AdminAuthSheetView(vm: vm)
        }
        .sheet(item: $vm.selectedOpsService) { svc in
            DevOpsInspectorSheetView(vm: vm, service: svc)
        }
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
            Task {
                await vm.verifyAdminToken()
                if vm.isAuthenticated {
                    await vm.fetchLiveHub(force: false)
                }
            }
        }
    }
}

// MARK: - Tab 1: Pure Native SwiftUI Executive Cockpit
struct NativeCockpitScrollView: View {
    @ObservedObject var vm: LiveHubViewModel
    @Binding var selectedTab: SuperAppTab
    @Binding var activeSheet: SheetWebTarget?

    private let panelBg = LinearGradient(
        colors: [Color(red: 0.094, green: 0.106, blue: 0.220), Color(red: 0.055, green: 0.063, blue: 0.141)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    private let emerald = Color(red: 0.204, green: 0.827, blue: 0.600)
    private let amber = Color(red: 0.984, green: 0.749, blue: 0.141)
    private let sky = Color(red: 0.220, green: 0.741, blue: 0.973)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. Top Native Executive Header
                headerSection

                // 2. Native RackNerd VPS + 20-Service Systemd/PM2 Matrix (Tập trung hiển thị bảng VPS)
                vpsMatrixCard

                // 3. Native 14-App Vector Launchpad Grid
                launchpadGridSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .refreshable {
            await vm.fetchLiveHub(force: true)
        }
    }

    // MARK: Header
    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [emerald, Color(red: 0.23, green: 0.51, blue: 0.96)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Buông Lơi Hub")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("PRO v4.2")
                        .font(.system(size: 9.5, weight: .heavy, design: .monospaced))
                        .foregroundColor(emerald)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(emerald.opacity(0.16))
                        .clipShape(Capsule())
                }

                Text("Executive DevOps Command Center")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(white: 0.62))
            }

            Spacer()

            // Admin Auth Button
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                vm.pendingOpsService = nil
                vm.showAuthSheet = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: vm.isAuthenticated ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 10.5, weight: .bold))
                    Text(vm.isAuthenticated ? "Admin" : "Ops")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundColor(vm.isAuthenticated ? emerald : amber)
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background((vm.isAuthenticated ? emerald : amber).opacity(0.15))
                .clipShape(Capsule())
                .overlay(Capsule().stroke((vm.isAuthenticated ? emerald : amber).opacity(0.35), lineWidth: 1))
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                Task { await vm.fetchLiveHub(force: true) }
            } label: {
                HStack(spacing: 5) {
                    Circle()
                        .fill(emerald)
                        .frame(width: 7, height: 7)
                    Text("\(vm.data?.health?.online_count ?? 14)/14")
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(emerald)
                        .rotationEffect(.degrees(vm.isSyncing ? 360 : 0))
                        .animation(vm.isSyncing ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: vm.isSyncing)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.07))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
            }
        }
    }

    // MARK: Panel 1 — Crypto Terminal Card
    private var cryptoCard: some View {
        let btc = vm.data?.bitcoin
        let price = btc?.price ?? 84520.0
        let chg = btc?.change_24h_pct ?? 1.43
        let isUp = chg >= 0
        let rsi = btc?.rsi_14 ?? 54
        let spark = btc?.sparkline ?? [83900, 84100, 84050, 84320, 84280, 84520]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(amber).frame(width: 8, height: 8)
                    Text("CRYPTO RADAR · LIVE BINANCE")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(white: 0.65))
                }
                Spacer()
                Button {
                    selectedTab = .crypto
                } label: {
                    Text("Mở Terminal ↗")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(emerald)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(emerald.opacity(0.14))
                        .clipShape(Capsule())
                }
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BTC / USDT")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(white: 0.6))
                    Text(String(format: "$%.2f", price))
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(amber)
                }
                Spacer()
                HStack(spacing: 6) {
                    Text(String(format: "%@%.2f%%", isUp ? "+" : "", chg))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(isUp ? emerald : Color.red)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background((isUp ? emerald : Color.red).opacity(0.16))
                        .clipShape(Capsule())

                    Text("RSI \(rsi)")
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.77, green: 0.71, blue: 0.99))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            // Native SwiftUI 24h Sparkline
            SparklineShapeView(points: spark, isUp: isUp)
                .frame(height: 52)

            // Sub Tickers: ETH, SOL, Fear & Greed
            HStack(spacing: 8) {
                subTickerPill(
                    sym: "ETH",
                    val: String(format: "$%.0f", btc?.eth_price ?? 1985),
                    chg: String(format: "%@%.1f%%", (btc?.eth_change_pct ?? 0) >= 0 ? "+" : "", btc?.eth_change_pct ?? 1.2),
                    isUp: (btc?.eth_change_pct ?? 0) >= 0
                )
                subTickerPill(
                    sym: "SOL",
                    val: String(format: "$%.1f", btc?.sol_price ?? 138.4),
                    chg: String(format: "%@%.1f%%", (btc?.sol_change_pct ?? 0) >= 0 ? "+" : "", btc?.sol_change_pct ?? 2.4),
                    isUp: (btc?.sol_change_pct ?? 0) >= 0
                )
                subTickerPill(
                    sym: "F&G",
                    val: "\(btc?.fear_greed_val ?? 55)",
                    chg: btc?.fear_greed_label ?? "Greed",
                    isUp: true
                )
            }
        }
        .padding(16)
        .background(panelBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private func subTickerPill(sym: String, val: String, chg: String, isUp: Bool) -> some View {
        HStack(spacing: 4) {
            Text(sym)
                .font(.system(size: 10.5, weight: .heavy, design: .monospaced))
                .foregroundColor(Color(white: 0.58))
            Spacer(minLength: 2)
            Text(val)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(chg)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(isUp ? emerald : Color.red)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Color.black.opacity(0.26))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: Panel 2 — RackNerd VPS & 14-Service Systemd Matrix
    private var vpsMatrixCard: some View {
        let vps = vm.data?.vps
        let services = vps?.services ?? []

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(emerald).frame(width: 8, height: 8)
                    Text("VPS 192.210.254.38 · UBUNTU 24.04")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(white: 0.65))
                }
                Spacer()
                Text("Up: \(vps?.uptime_str ?? "9d 7h")")
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(emerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(emerald.opacity(0.14))
                    .clipShape(Capsule())
            }

            HStack(spacing: 8) {
                vpsMeter(label: "CPU", val: String(format: "%.0f%%", vps?.cpu_pct ?? 6), pct: (vps?.cpu_pct ?? 6) / 100.0)
                vpsMeter(label: "RAM", val: String(format: "%.1fG", vps?.ram_used_gb ?? 2.1), pct: (vps?.ram_pct ?? 55) / 100.0)
                vpsMeter(label: "SSD", val: "\(vps?.disk_pct ?? 57)%", pct: Double(vps?.disk_pct ?? 57) / 100.0)
                vpsMeter(label: "SWAP", val: String(format: "%.0fM", vps?.swap_used_mb ?? 980), pct: (vps?.swap_pct ?? 48) / 100.0)
            }

            // Quick Gateway Recovery Row
            VStack(alignment: .leading, spacing: 6) {
                Text("⚡ CỨU HỘ GATEWAY & ĐIỀU KHIỂN DAEMONS (CHẠM ĐỂ RESTART / LOG)")
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(white: 0.6))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Button {
                            vm.selectServiceForOps(SystemdServiceItem(unit: "all-gateways", label: "Toàn bộ Gateway", active: true, manager: "gateway-suite", group: "gateway"))
                        } label: {
                            Text("🚀 Restart All Gateways")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(amber)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(amber.opacity(0.16))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(amber.opacity(0.4), lineWidth: 1))
                        }

                        Button {
                            vm.selectServiceForOps(SystemdServiceItem(unit: "hermes-gateway", label: "Hermes Gateway", active: true, manager: "systemd-user", group: "gateway"))
                        } label: {
                            Text("🤖 Hermes Gateway")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }

                        Button {
                            vm.selectServiceForOps(SystemdServiceItem(unit: "cloudflared", label: "CF Tunnel", active: true, manager: "systemd", group: "gateway"))
                        } label: {
                            Text("🌐 CF Tunnel")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }

                        Button {
                            vm.selectServiceForOps(SystemdServiceItem(unit: "nginx", label: "Nginx Proxy", active: true, manager: "systemd", group: "gateway"))
                        } label: {
                            Text("⚡ Nginx")
                                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.07))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }

            if !services.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
                    ForEach(services) { svc in
                        Button {
                            vm.selectServiceForOps(svc)
                        } label: {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(svc.active ? emerald : Color.red)
                                    .frame(width: 6, height: 6)
                                Text(svc.label)
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(panelBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private func vpsMeter(label: String, val: String, pct: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(white: 0.58))
                Spacer()
                Text(val)
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(pct > 0.85 ? Color.red : (pct > 0.68 ? amber : emerald))
                        .frame(width: max(4, geo.size.width * CGFloat(min(1.0, max(0.05, pct)))))
                }
            }
            .frame(height: 5)
        }
        .padding(8)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: Panel 3 — Sài Gòn Weather + Native GDrive Audio Deck
    private var weatherAndMusicCard: some View {
        let w = vm.data?.weather
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(sky).frame(width: 8, height: 8)
                    Text("THIÊN TƯỢNG · TP. HỒ CHÍ MINH")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(white: 0.65))
                }
                Spacer()
                Button {
                    if let u = URL(string: "https://weather.buongloi.me") {
                        activeSheet = SheetWebTarget(title: "Thiên Tượng Radar", url: u)
                    }
                } label: {
                    Text("Radar ↗")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(sky)
                }
            }

            HStack(spacing: 14) {
                Text(String(format: "%.0f°C", w?.temp ?? 27))
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(sky)

                VStack(alignment: .leading, spacing: 4) {
                    Text((w?.description ?? "Có mây").capitalized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Text("💧 \(w?.humidity ?? 78)%")
                        Text("💨 \(String(format: "%.0f", w?.wind_speed ?? 7)) km/h")
                        Text("🌡️ Cảm giác \(String(format: "%.0f°C", w?.feels_like ?? 29))")
                    }
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(white: 0.68))
                }
                Spacer()
            }

            Divider().background(Color.white.opacity(0.1))

            // Native AVPlayer GDrive Studio Deck
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: vm.isPlayingAudio ? "waveform" : "music.note")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.green)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.currentTrackTitle)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(vm.currentTrackArtist)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(white: 0.62))
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Button(action: { vm.prevTrack() }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }

                        Button(action: { vm.togglePlay() }) {
                            Image(systemName: vm.isPlayingAudio ? "pause.fill" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.green)
                                .clipShape(Circle())
                        }

                        Button(action: { vm.nextTrack() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                    }
                }

                if !vm.tracks.isEmpty {
                    HStack {
                        Menu {
                            ForEach(Array(vm.tracks.prefix(40).enumerated()), id: \.offset) { idx, t in
                                Button("🎵 \(t.title) — \(t.artist)") {
                                    vm.playTrack(at: idx)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 11))
                                Text("Chọn nhanh từ \(vm.data?.music?.total_tracks ?? vm.tracks.count) bài nhạc Google Drive")
                                    .font(.system(size: 11.5, weight: .semibold))
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        }

                        Button {
                            if let u = URL(string: "https://music.buongloi.me") {
                                activeSheet = SheetWebTarget(title: "Buông Lơi Music", url: u)
                            }
                        } label: {
                            Text("Full App ↗")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.green)
                                .padding(.horizontal, 8)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.green.opacity(0.28), lineWidth: 1)
            )
        }
        .padding(16)
        .background(panelBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    // MARK: Panel 4 — Live Intelligence Feed (AI News & Giveaways)
    private var intelligenceFeedCard: some View {
        let headlines = vm.data?.news?.headlines ?? []
        let giveaways = vm.data?.giveaway?.recent ?? []

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Button {
                        vm.feedTab = 0
                    } label: {
                        Text("📰 Tin Nóng AI (\(vm.data?.news?.total_articles ?? 4023))")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(vm.feedTab == 0 ? .white : Color(white: 0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(vm.feedTab == 0 ? emerald.opacity(0.22) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    Button {
                        vm.feedTab = 1
                    } label: {
                        Text("🎁 Bản Quyền (\(vm.data?.giveaway?.total ?? 63))")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(vm.feedTab == 1 ? .white : Color(white: 0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(vm.feedTab == 1 ? emerald.opacity(0.22) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(3)
                .background(Color.black.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Spacer()

                Button {
                    if vm.feedTab == 0 {
                        selectedTab = .news
                    } else if let u = URL(string: "https://giveaway.buongloi.live") {
                        activeSheet = SheetWebTarget(title: "Giveaway Bot", url: u)
                    }
                } label: {
                    Text("Tất cả ↗")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(emerald)
                }
            }

            VStack(spacing: 7) {
                if vm.feedTab == 0 {
                    ForEach(headlines.prefix(5)) { item in
                        Button {
                            if let s = item.url, let u = URL(string: s) {
                                activeSheet = SheetWebTarget(title: item.source ?? "Tin Nóng AI", url: u)
                            } else {
                                selectedTab = .news
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(item.source ?? "AI")
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundColor(emerald)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(emerald.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))

                                Text(item.title ?? "")
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                } else {
                    ForEach(giveaways.prefix(5)) { item in
                        Button {
                            if let s = item.url, let u = URL(string: s) {
                                activeSheet = SheetWebTarget(title: item.source ?? "Giveaway", url: u)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(item.source ?? "FREE")
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.pink)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.pink.opacity(0.16))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))

                                Text(item.title ?? "")
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(panelBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    // MARK: Section 6 — Native 14-App Vector Launchpad Grid
    private var launchpadGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🚀 TRẠM KHỞI CHẠY 14 ỨNG DỤNG")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(Color(white: 0.75))
                Spacer()
                Button {
                    if let u = URL(string: "https://hub.buongloi.me/?mode=2d") {
                        activeSheet = SheetWebTarget(title: "Nông Trại Buông Lơi 2D", url: u)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("🌾 Nông Trại 2D")
                            .font(.system(size: 11.5, weight: .bold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(emerald)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(ECOSYSTEM_APPS) { app in
                    let ping = vm.data?.health?.results?[app.healthKey]
                    let isUp = ping?.ok ?? true
                    let ms = ping?.latency_ms ?? 0

                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let u = URL(string: app.urlString) {
                            activeSheet = SheetWebTarget(title: app.name, url: u)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(app.hexColor.opacity(0.18))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(app.hexColor.opacity(0.4), lineWidth: 1)
                                        )

                                    Image(systemName: app.sfSymbol)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(app.hexColor)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(isUp ? emerald : Color.red)
                                        .frame(width: 6, height: 6)
                                    Text(ms > 0 ? "\(ms)ms" : "Online")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(white: 0.7))
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.black.opacity(0.28))
                                .clipShape(Capsule())
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(app.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(app.role)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(white: 0.6))
                                    .lineLimit(1)
                            }
                        }
                        .padding(13)
                        .background(panelBg)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Native SwiftUI 24h Sparkline Chart
struct SparklineShapeView: View {
    let points: [Double]
    let isUp: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minVal = points.min() ?? 0
            let maxVal = points.max() ?? 1
            let range = max(maxVal - minVal, 1)
            let strokeColor = isUp ? Color(red: 0.204, green: 0.827, blue: 0.600) : Color.red

            if points.count > 1 {
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h))
                        for (idx, val) in points.enumerated() {
                            let x = (CGFloat(idx) / CGFloat(points.count - 1)) * w
                            let y = h - CGFloat((val - minVal) / range) * (h - 8) - 4
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [strokeColor.opacity(0.32), strokeColor.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    Path { path in
                        for (idx, val) in points.enumerated() {
                            let x = (CGFloat(idx) / CGFloat(points.count - 1)) * w
                            let y = h - CGFloat((val - minVal) / range) * (h - 8) - 4
                            if idx == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

// MARK: - Persistent Multi-WebView Deck for Tabs 2..5 (Zero Reload Switching)
struct PersistentWebDeck: UIViewRepresentable {
    let selectedTab: SuperAppTab
    let authToken: String

    func makeCoordinator() -> DeckCoordinator {
        DeckCoordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor(red: 0.035, green: 0.043, blue: 0.098, alpha: 1.0)
        context.coordinator.containerView = container
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.showTab(selectedTab, authToken: authToken)
    }

    final class DeckCoordinator: NSObject, WKScriptMessageHandler {
        weak var containerView: UIView?
        private var webViews: [SuperAppTab: WKWebView] = [:]

        func showTab(_ tab: SuperAppTab, authToken: String) {
            guard let container = containerView, var targetURL = tab.webURL else { return }
            if tab == .farm, !authToken.isEmpty,
               let encoded = authToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let authedURL = URL(string: "https://hub.buongloi.me/?mode=2d&embed=ios&token=\(encoded)") {
                targetURL = authedURL
            }

            let wv: WKWebView
            if let existing = webViews[tab] {
                wv = existing
            } else {
                let config = WKWebViewConfiguration()
                config.allowsInlineMediaPlayback = true
                config.mediaTypesRequiringUserActionForPlayback = []
                config.defaultWebpagePreferences.allowsContentJavaScript = true
                config.applicationNameForUserAgent = "BuongLoiHubApp/4.0 (iOS)"
                config.userContentController.add(self, name: "haptic")

                let created = WKWebView(frame: container.bounds, configuration: config)
                created.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                created.allowsBackForwardNavigationGestures = true
                let dark = UIColor(red: 0.035, green: 0.043, blue: 0.098, alpha: 1.0)
                created.backgroundColor = dark
                created.isOpaque = false
                created.scrollView.backgroundColor = dark

                let refresh = UIRefreshControl()
                refresh.tintColor = UIColor(red: 0.204, green: 0.827, blue: 0.600, alpha: 1.0)
                refresh.addTarget(self, action: #selector(handlePullToRefresh(_:)), for: .valueChanged)
                created.scrollView.refreshControl = refresh

                container.addSubview(created)
                created.load(URLRequest(url: targetURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 25))
                webViews[tab] = created
                wv = created
            }

            for (t, view) in webViews {
                view.isHidden = (t != tab)
            }
            container.bringSubviewToFront(wv)
        }

        @objc private func handlePullToRefresh(_ sender: UIRefreshControl) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if let scrollView = sender.superview as? UIScrollView,
               let wv = scrollView.superview as? WKWebView {
                wv.reload()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                sender.endRefreshing()
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "haptic" {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}

// MARK: - In-App Sheet Browser for Individual Apps / Articles
struct InAppBrowserSheet: View {
    let target: SheetWebTarget
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SingleSheetWebView(url: target.url)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(target.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Đóng") {
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Link(destination: target.url) {
                            Image(systemName: "safari")
                        }
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

struct SingleSheetWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Native Admin Authentication & Password Management Sheet
struct AdminAuthSheetView: View {
    @ObservedObject var vm: LiveHubViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var usernameInput: String = "admin"
    @State private var passwordInput: String = ""
    @State private var currentPassInput: String = ""
    @State private var newUserInput: String = "admin"
    @State private var newPassInput: String = ""
    @State private var feedbackText: String = ""
    @State private var isError: Bool = false
    @State private var isBusy: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if !vm.isAuthenticated {
                        Text("Xác thực quyền Admin để mở khóa tính năng Khởi động lại (Restart) ứng dụng bị treo, Restart Gateway và xem Live Journalctl/PM2 Logs.")
                            .font(.system(size: 13.5))
                            .foregroundColor(Color(white: 0.7))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tài khoản Admin")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(white: 0.78))
                            TextField("admin", text: $usernameInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(12)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mật khẩu Admin")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(white: 0.78))
                            SecureField("Nhập mật khẩu quản trị...", text: $passwordInput)
                                .padding(12)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.white)
                        }

                        if !feedbackText.isEmpty {
                            Text(feedbackText)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isError ? Color.red : Color.green)
                        }

                        Button {
                            Task {
                                isBusy = true
                                let (ok, msg) = await vm.loginAdmin(username: usernameInput, password: passwordInput)
                                isBusy = false
                                isError = !ok
                                feedbackText = msg
                                if ok {
                                    let target = vm.pendingOpsService
                                    vm.pendingOpsService = nil
                                    dismiss()
                                    if let svc = target {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            vm.selectedOpsService = svc
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if isBusy { ProgressView().tint(.white) }
                                Text("🔓 Đăng Nhập & Mở Khóa Ops")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(red: 0.063, green: 0.725, blue: 0.506))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isBusy)
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Đang đăng nhập quyền Quản trị")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.65))
                                Text("👤 \(vm.adminUsername)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            Button("Đăng xuất") {
                                vm.logoutAdmin()
                                dismiss()
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Divider().background(Color.white.opacity(0.15))

                        Text("🔑 Đổi mật khẩu Admin")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)

                        SecureField("Mật khẩu hiện tại", text: $currentPassInput)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)

                        TextField("Tên tài khoản mới (tùy chọn)", text: $newUserInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)

                        SecureField("Mật khẩu mới (tối thiểu 4 ký tự)", text: $newPassInput)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)

                        if !feedbackText.isEmpty {
                            Text(feedbackText)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isError ? Color.red : Color.green)
                        }

                        Button {
                            Task {
                                isBusy = true
                                let (ok, msg) = await vm.changeAdminPassword(
                                    currentPassword: currentPassInput,
                                    newUsername: newUserInput,
                                    newPassword: newPassInput
                                )
                                isBusy = false
                                isError = !ok
                                feedbackText = msg
                                if ok {
                                    currentPassInput = ""
                                    newPassInput = ""
                                }
                            }
                        } label: {
                            Text("💾 Lưu mật khẩu mới")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isBusy)
                    }
                }
                .padding(20)
            }
            .background(Color(red: 0.047, green: 0.059, blue: 0.125).ignoresSafeArea())
            .navigationTitle("🔐 Bảo Mật DevOps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
            .onAppear {
                usernameInput = vm.adminUsername
                newUserInput = vm.adminUsername
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Native DevOps Service Restart & Live Logs Inspector Sheet
struct DevOpsInspectorSheetView: View {
    @ObservedObject var vm: LiveHubViewModel
    let service: SystemdServiceItem
    @Environment(\.dismiss) private var dismiss

    @State private var logsText: String = "⏳ Đang tải log thời gian thực từ VPS 192.210.254.38..."
    @State private var statusBanner: String = ""
    @State private var isError: Bool = false
    @State private var isRestarting: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text((service.manager ?? "systemd").uppercased())
                        .font(.system(size: 10.5, weight: .heavy, design: .monospaced))
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cyan.opacity(0.16))
                        .clipShape(Capsule())

                    Text(service.active ? "● ACTIVE (ONLINE)" : "● INACTIVE / DOWN")
                        .font(.system(size: 10.5, weight: .heavy, design: .monospaced))
                        .foregroundColor(service.active ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background((service.active ? Color.green : Color.red).opacity(0.16))
                        .clipShape(Capsule())

                    Spacer()
                }

                HStack(spacing: 10) {
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        Task {
                            isRestarting = true
                            statusBanner = "⏳ Đang gửi lệnh Restart \(service.label)..."
                            isError = false
                            let (ok, msg) = await vm.restartService(unit: service.unit)
                            isRestarting = false
                            isError = !ok
                            statusBanner = ok ? "✅ \(msg)" : "❌ \(msg)"
                            if ok && service.unit != "all-gateways" {
                                logsText = await vm.fetchServiceLogs(unit: service.unit)
                            }
                        }
                    } label: {
                        HStack {
                            if isRestarting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.clockwise.circle.fill")
                            }
                            Text(isRestarting ? "Đang Restart..." : "Khởi Động Lại (Restart)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isRestarting)

                    Button {
                        Task {
                            logsText = "⏳ Đang làm mới log..."
                            logsText = await vm.fetchServiceLogs(unit: service.unit)
                        }
                    } label: {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if !statusBanner.isEmpty {
                    Text(statusBanner)
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(isError ? .red : .green)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background((isError ? Color.red : Color.green).opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Text("TERMINAL LIVE LOGS (\(service.unit))")
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(white: 0.6))

                ScrollView {
                    Text(logsText)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.65, green: 0.95, blue: 0.81))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                }
                .background(Color.black.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }
            .padding(16)
            .background(Color(red: 0.047, green: 0.059, blue: 0.125).ignoresSafeArea())
            .navigationTitle("\(service.label)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
            .task {
                logsText = await vm.fetchServiceLogs(unit: service.unit)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Full-Screen Mandatory Login Gate View (v4.2)
struct FullScreenLoginGateView: View {
    @ObservedObject var vm: LiveHubViewModel
    @State private var usernameInput: String = "admin"
    @State private var passwordInput: String = ""
    @State private var feedbackText: String = ""
    @State private var isError: Bool = false
    @State private var isBusy: Bool = false

    private let emerald = Color(red: 0.204, green: 0.827, blue: 0.600)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.025, green: 0.035, blue: 0.085), Color(red: 0.055, green: 0.075, blue: 0.165)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Spacer(minLength: 36)

                    // Logo Orb
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [emerald.opacity(0.28), Color.blue.opacity(0.28)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 72, height: 72)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(emerald.opacity(0.5), lineWidth: 1.2)
                            )

                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(emerald)
                    }

                    Text("SECURITY GATEWAY · PRO v4.2")
                        .font(.system(size: 10.5, weight: .heavy, design: .monospaced))
                        .foregroundColor(emerald)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(emerald.opacity(0.15))
                        .clipShape(Capsule())

                    VStack(spacing: 6) {
                        Text("Buông Lơi Hub")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("Cổng Chỉ Huy Hệ Sinh Thái Số & DevOps 20 Daemons.\nVui lòng đăng nhập để mở khóa truy cập hệ thống.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.68))
                            .multilineTextAlignment(.center)
                    }

                    if vm.isCheckingAuth {
                        HStack(spacing: 10) {
                            ProgressView().tint(emerald)
                            Text("Đang kiểm tra phiên bảo mật...")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(white: 0.75))
                        }
                        .padding(.vertical, 20)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Tài khoản truy cập")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(white: 0.78))

                                TextField("admin", text: $usernameInput)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(13)
                                    .background(Color.black.opacity(0.38))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Mật khẩu bảo mật")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(white: 0.78))

                                SecureField("Nhập mật khẩu để truy cập Hub...", text: $passwordInput)
                                    .padding(13)
                                    .background(Color.black.opacity(0.38))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                            }

                            if !feedbackText.isEmpty {
                                Text(feedbackText)
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundColor(isError ? .red : emerald)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background((isError ? Color.red : emerald).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                Task {
                                    isBusy = true
                                    feedbackText = ""
                                    let (ok, msg) = await vm.loginAdmin(username: usernameInput, password: passwordInput)
                                    isBusy = false
                                    isError = !ok
                                    if ok {
                                        await vm.fetchLiveHub(force: true)
                                    } else {
                                        feedbackText = "❌ \(msg)"
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if isBusy {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "key.fill")
                                    }
                                    Text(isBusy ? "Đang xác thực..." : "Xác Thực & Truy Cập Hệ Thống")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.063, green: 0.725, blue: 0.506), Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isBusy)
                        }
                        .padding(22)
                        .background(Color(red: 0.075, green: 0.095, blue: 0.195).opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                    }

                    Text("🛡️ Bảo vệ bởi PBKDF2-SHA256 & HMAC Session · VPS 192.210.254.38")
                        .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(white: 0.48))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            usernameInput = vm.adminUsername
        }
    }
}

