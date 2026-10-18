import UIKit
import Network

class VPNManager: ObservableObject {
    @Published var isVPNActive: Bool = false
    @Published var errorMessage: String?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "vpn.monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let active = path.usesInterfaceType(.other) || self?.checkVPNInterface() == true
            DispatchQueue.main.async {
                self?.isVPNActive = active
            }
        }
        monitor.start(queue: queue)
    }

    private func checkVPNInterface() -> Bool {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return false }
        defer { freeifaddrs(ifaddr) }
        var ptr = ifaddr
        while let current = ptr {
            let name = String(cString: current.pointee.ifa_name)
            if name.hasPrefix("utun") || name.hasPrefix("ipsec") || name.hasPrefix("ppp") {
                return true
            }
            ptr = current.pointee.ifa_next
        }
        return false
    }

    var statusText: String {
        isVPNActive ? "Đã kết nối" : "Chưa kết nối"
    }

    func openVPNSettings() {
        let candidates = [
            "App-Prefs:root=VPN",
            "prefs:root=VPN",
            "App-Prefs:VPN",
        ]
        for scheme in candidates {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        // Fallback: open root Settings, user navigates manually
        if let url = URL(string: "App-Prefs:") ?? URL(string: "prefs:") {
            UIApplication.shared.open(url)
        }
    }
}
