import SwiftUI

struct ContentView: View {
    @StateObject private var vpn = VPNManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 6) {
                    Text("CheatiOSVip")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    Text("Free Fire Proxy")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                }

                ZStack {
                    Circle()
                        .fill(vpn.isVPNActive
                              ? Color.green.opacity(0.12)
                              : Color.white.opacity(0.05))
                        .frame(width: 170, height: 170)
                    Circle()
                        .fill(vpn.isVPNActive
                              ? Color.green.opacity(0.22)
                              : Color.white.opacity(0.08))
                        .frame(width: 130, height: 130)
                    Image(systemName: vpn.isVPNActive ? "lock.shield.fill" : "lock.shield")
                        .font(.system(size: 52))
                        .foregroundColor(vpn.isVPNActive ? .green : Color(white: 0.4))
                }
                .animation(.easeInOut(duration: 0.3), value: vpn.isVPNActive)

                VStack(spacing: 6) {
                    Text(vpn.statusText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(vpn.isVPNActive ? .green : Color(white: 0.5))
                    if vpn.isVPNActive {
                        Text("proxy.cheatiosvip.net")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(white: 0.35))
                    }
                }

                Button(action: { vpn.openVPNSettings() }) {
                    Text(vpn.isVPNActive ? "Tắt VPN (mở Settings)" : "Bật VPN (mở Settings)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: vpn.isVPNActive
                                    ? [Color(hex: "c0392b"), Color(hex: "e74c3c")]
                                    : [Color(hex: "5b8fff"), Color(hex: "a855f7")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)

                Spacer()

                Text("Bật VPN xong → mở Free Fire")
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
        self.init(
            red: Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8) & 0xFF) / 255,
            blue: Double(v & 0xFF) / 255
        )
    }
}
