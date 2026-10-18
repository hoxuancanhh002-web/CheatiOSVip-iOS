import Network
import Combine

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
        // iOS 16+: mở thẳng trang VPN trong Settings
        if let url = URL(string: "App-Prefs:root=VPN") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        // Fallback
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
