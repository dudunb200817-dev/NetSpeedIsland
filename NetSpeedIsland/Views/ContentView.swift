import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SpeedMonitorViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    statusHeader
                    speedCardsRow
                    sparklineCard
                    sessionStatsCard
                    controlSection
                }
                .padding()
            }
            .background(Color(red: 0.05, green: 0.06, blue: 0.09).ignoresSafeArea())
            .navigationTitle("灵动网速")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清零统计") {
                        viewModel.resetSessionStats()
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private var statusHeader: some View {
        HStack {
            Label(viewModel.networkType, systemImage: networkIconName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1), in: Capsule())

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isIslandActive ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                Text(viewModel.isIslandActive ? "灵动岛监控中" : "灵动岛未开启")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var speedCardsRow: some View {
        HStack(spacing: 12) {
            speedCard(
                title: "实时下载",
                symbol: "arrow.down.circle.fill",
                color: Color(red: 0.22, green: 0.85, blue: 0.56),
                value: SpeedFormatter.formatSpeed(viewModel.downloadSpeed)
            )
            speedCard(
                title: "实时上传",
                symbol: "arrow.up.circle.fill",
                color: Color(red: 0.30, green: 0.72, blue: 1.0),
                value: SpeedFormatter.formatSpeed(viewModel.uploadSpeed)
            )
        }
    }

    private func speedCard(title: String, symbol: String, color: Color, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var sparklineCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("下载速度波动（近 30 次采样）")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("峰值 \(SpeedFormatter.formatSpeed(viewModel.peakDownloadSpeed))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.56))
            }

            SpeedSparklineView(samples: viewModel.downloadHistory)
                .frame(height: 92)
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var sessionStatsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("本次累计下载")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(SpeedFormatter.formatBytes(viewModel.totalDownloadBytes))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.white)
            }
            Spacer()
            Divider()
                .frame(height: 28)
                .background(Color.white.opacity(0.15))
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("本次累计上传")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(SpeedFormatter.formatBytes(viewModel.totalUploadBytes))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var controlSection: some View {
        VStack(spacing: 14) {
            Button(action: viewModel.toggleLiveActivity) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isIslandActive ? "stop.circle.fill" : "waveform.path.ecg")
                    Text(viewModel.isIslandActive ? "停止灵动岛监控" : "开启灵动岛实时网速")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    viewModel.isIslandActive
                        ? Color.red.opacity(0.85)
                        : Color(red: 0.16, green: 0.72, blue: 0.52),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .foregroundStyle(.white)
            }

            if let message = viewModel.statusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(spacing: 12) {
                Toggle(isOn: $viewModel.enableBackgroundKeepAlive) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("后台持续刷新")
                            .font(.subheadline.weight(.medium))
                        Text("通过静默音频防止 iOS 挂起，不影响听歌或看视频")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(Color(red: 0.22, green: 0.85, blue: 0.56))

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Text("刷新频率")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Picker("刷新频率", selection: $viewModel.refreshInterval) {
                        Text("1 秒").tag(1.0)
                        Text("2 秒").tag(2.0)
                        Text("3 秒").tag(3.0)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("提示：受 iOS 系统机制限制，单次灵动岛实时活动最长可持续 8 小时，到期后重新点一下开启即可。")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var networkIconName: String {
        switch viewModel.networkType {
        case "Wi-Fi":
            return "wifi"
        case "蜂窝网络":
            return "antenna.radiowaves.left.and.right"
        case "无网络":
            return "wifi.slash"
        default:
            return "network"
        }
    }
}

private struct SpeedSparklineView: View {
    let samples: [Double]

    var body: some View {
        GeometryReader { geo in
            let maxVal = max(samples.max() ?? 1, 1024)
            let count = max(samples.count - 1, 1)
            let stepX = geo.size.width / CGFloat(count)

            let linePath = Path { path in
                for (idx, value) in samples.enumerated() {
                    let x = CGFloat(idx) * stepX
                    let ratio = min(max(value / maxVal, 0), 1)
                    let y = geo.size.height * (1 - CGFloat(ratio))
                    if idx == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }

            let fillPath = Path { path in
                path.addPath(linePath)
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                path.closeSubpath()
            }

            ZStack {
                fillPath
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.85, blue: 0.56).opacity(0.35),
                                Color(red: 0.22, green: 0.85, blue: 0.56).opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                linePath
                    .stroke(
                        Color(red: 0.22, green: 0.85, blue: 0.56),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
            }
        }
    }
}
