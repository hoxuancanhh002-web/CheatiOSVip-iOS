import NetworkExtension

class VPNManager: ObservableObject {
    @Published var status: NEVPNStatus = .invalid

    private let manager = NEVPNManager.shared()

    var isConnected: Bool { status == .connected }
    var isConnecting: Bool { status == .connecting || status == .reasserting }

    var statusText: String {
        switch status {
        case .connected:     return "Đã kết nối"
        case .connecting:    return "Đang kết nối..."
        case .disconnecting: return "Đang ngắt..."
        case .reasserting:   return "Đang kết nối lại..."
        case .disconnected:  return "Chưa kết nối"
        case .invalid:       return "Chưa cài profile"
        @unknown default:    return "Không xác định"
        }
    }

    init() {
        loadStatus()
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.loadStatus() }
    }

    private func loadStatus() {
        manager.loadFromPreferences { [weak self] _ in
            DispatchQueue.main.async {
                self?.status = self?.manager.connection.status ?? .invalid
            }
        }
    }

    func toggle() {
        if isConnected || isConnecting {
            manager.connection.stopVPNTunnel()
        } else {
            connect()
        }
    }

    private func connect() {
        // Load the VPN config installed via mobileconfig, then start it
        manager.loadFromPreferences { [weak self] error in
            guard let self else { return }
            guard self.manager.protocolConfiguration != nil else {
                // Profile not installed yet
                DispatchQueue.main.async { self.status = .invalid }
                return
            }
            self.manager.isEnabled = true
            self.manager.saveToPreferences { [weak self] _ in
                guard let self else { return }
                self.manager.loadFromPreferences { [weak self] _ in
                    try? self?.manager.connection.startVPNTunnel()
                }
            }
        }
    }
}
