import SwiftUI

struct ContentView: View {
    @StateObject private var vpn = VPNManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 6) {
                    Text("CheatiOSVip")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Free Fire Proxy")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                }

                // Status ring
                ZStack {
                    Circle()
                        .fill(vpn.isConnected
                              ? Color.green.opacity(0.12)
                              : Color.white.opacity(0.05))
                        .frame(width: 170, height: 170)
                    Circle()
                        .fill(vpn.isConnected
                              ? Color.green.opacity(0.22)
                              : Color.white.opacity(0.08))
                        .frame(width: 130, height: 130)
                    Image(systemName: vpn.isConnected ? "lock.shield.fill" : "lock.shield")
                        .font(.system(size: 52))
                        .foregroundColor(vpn.isConnected ? .green : Color(white: 0.4))
                }
                .animation(.easeInOut(duration: 0.3), value: vpn.isConnected)

                // Status label
                VStack(spacing: 6) {
                    Text(vpn.statusText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(vpn.isConnected ? .green : Color(white: 0.5))
                    if vpn.isConnected {
                        Text("proxy.cheatiosvip.net")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(white: 0.35))
                    }
                }

                // Button
                Button(action: { vpn.toggle() }) {
                    Text(vpn.isConnected ? "Tắt VPN" : "Bật VPN")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Group {
                                if vpn.isConnected {
                                    LinearGradient(colors: [Color(hex: "c0392b"), Color(hex: "e74c3c")],
                                                   startPoint: .leading, endPoint: .trailing)
                                } else {
                                    LinearGradient(colors: [Color(hex: "5b8fff"), Color(hex: "a855f7")],
                                                   startPoint: .leading, endPoint: .trailing)
                                }
                            }
                        )
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .disabled(vpn.isConnecting)
                .opacity(vpn.isConnecting ? 0.6 : 1)

                Spacer()

                if let err = vpn.errorMessage {
                    Text(err)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                Text("Bật VPN trước khi mở Free Fire")
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.3))
                    .padding(.bottom, 12)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
