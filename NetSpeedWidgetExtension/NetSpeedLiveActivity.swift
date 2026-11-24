import ActivityKit
import SwiftUI
import WidgetKit

struct NetSpeedLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NetSpeedAttributes.self) { context in
            // Lock Screen / Notification Banner presentation
            lockScreenView(state: context.state)
                .activityBackgroundTint(Color(red: 0.08, green: 0.09, blue: 0.13))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island (long press)
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("下载", systemImage: "arrow.down")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.56))
                        Text(SpeedFormatter.formatSpeed(context.state.downloadBytesPerSec))
                            .font(.headline.weight(.bold).monospacedDigit())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Label("上传", systemImage: "arrow.up")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.30, green: 0.72, blue: 1.0))
                        Text(SpeedFormatter.formatSpeed(context.state.uploadBytesPerSec))
                            .font(.headline.weight(.bold).monospacedDigit())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.networkType)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("累计 ↓ \(SpeedFormatter.formatBytes(context.state.totalDownloadBytes))")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("累计 ↑ \(SpeedFormatter.formatBytes(context.state.totalUploadBytes))")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.56))
                    Text(SpeedFormatter.formatCompactSpeed(context.state.downloadBytesPerSec))
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            } compactTrailing: {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 0.30, green: 0.72, blue: 1.0))
                    Text(SpeedFormatter.formatCompactSpeed(context.state.uploadBytesPerSec))
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            } minimal: {
                Text(SpeedFormatter.formatCompactSpeed(context.state.downloadBytesPerSec))
                    .font(.system(size: 10, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.56))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private func lockScreenView(state: NetSpeedAttributes.ContentState) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(Color(red: 0.22, green: 0.85, blue: 0.56))
                    Text("下载")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(SpeedFormatter.formatSpeed(state.downloadBytesPerSec))
                    .font(.headline.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(state.networkType)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.12), in: Capsule())
                Text("总计 \(SpeedFormatter.formatBytes(state.totalDownloadBytes + state.totalUploadBytes))")
                    .font(.system(size: 10).monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text("上传")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(Color(red: 0.30, green: 0.72, blue: 1.0))
                }
                Text(SpeedFormatter.formatSpeed(state.uploadBytesPerSec))
                    .font(.headline.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
