import NetworkExtension
import Security

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
        case .disconnected, .invalid: return "Chưa kết nối"
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
        manager.loadFromPreferences { [weak self] _ in
            guard let self else { return }

            let proto = NEVPNProtocolIKEv2()
            proto.serverAddress = "proxy.cheatiosvip.net"
            proto.remoteIdentifier = "proxy.cheatiosvip.net"
            proto.localIdentifier = "vpn"
            proto.authenticationMethod = .sharedSecret
            proto.sharedSecretReference = self.keychainRef(
                service: "net.cheatiosvip.app.psk",
                account: "psk",
                value: "vpn"
            )
            proto.username = "vpn"
            proto.passwordReference = self.keychainRef(
                service: "net.cheatiosvip.app.password",
                account: "vpn",
                value: "vpn"
            )
            proto.useExtendedAuthentication = true
            proto.disconnectOnSleep = false

            // Proxy — same as mobileconfig
            let proxy = NEProxySettings()
            proxy.httpEnabled = true
            proxy.httpServer = NEProxyServer(address: "proxy.cheatiosvip.net", port: 8888)
            proxy.httpsEnabled = true
            proxy.httpsServer = NEProxyServer(address: "proxy.cheatiosvip.net", port: 8888)
            proxy.exceptionList = [
                "*.garena.com", "*.garena.gg", "*.sea.com",
                "*.seagroup.com", "*.razer.com",
                "*.facebook.com", "*.facebook.net", "*.fbcdn.net",
                "*.appsflyersdk.com", "*.ppmainecoonghj.com"
            ]
            proto.proxySettings = proxy

            self.manager.protocolConfiguration = proto
            self.manager.localizedDescription = "CheatiOSVip VPN"
            self.manager.isEnabled = true

            self.manager.saveToPreferences { [weak self] _ in
                guard let self else { return }
                self.manager.loadFromPreferences { [weak self] _ in
                    try? self?.manager.connection.startVPNTunnel()
                }
            }
        }
    }

    private func keychainRef(service: String, account: String, value: String) -> Data {
        let data = value.data(using: .utf8)!
        let q: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecReturnPersistentRef: true,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(q as CFDictionary)
        var ref: AnyObject?
        if SecItemAdd(q as CFDictionary, &ref) == errSecSuccess, let d = ref as? Data {
            return d
        }
        return data
    }
}
