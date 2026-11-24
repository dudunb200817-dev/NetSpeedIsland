import ActivityKit
import Combine
import Foundation

@MainActor
final class SpeedMonitorViewModel: ObservableObject {
    @Published var downloadSpeed: Double = 0
    @Published var uploadSpeed: Double = 0
    @Published var peakDownloadSpeed: Double = 0
    @Published var totalDownloadBytes: UInt64 = 0
    @Published var totalUploadBytes: UInt64 = 0
    @Published var networkType: String = "检测中"
    @Published var downloadHistory: [Double] = Array(repeating: 0, count: 30)

    @Published var isIslandActive: Bool = false
    @Published var enableBackgroundKeepAlive: Bool = true {
        didSet {
            if isIslandActive {
                if enableBackgroundKeepAlive {
                    keepAlive.start()
                } else {
                    keepAlive.stop()
                }
            }
        }
    }
    @Published var refreshInterval: Double = 1.0 {
        didSet {
            restartTimer()
        }
    }
    @Published var statusMessage: String?

    private let sampler = NetworkSpeedSampler()
    private let keepAlive = SilentAudioKeepAlive()
    private var timer: Timer?
    private var currentActivity: Activity<NetSpeedAttributes>?

    init() {
        sampler.resetBaseline()
        syncExistingActivity()
        restartTimer()
    }

    deinit {
        timer?.invalidate()
    }

    func toggleLiveActivity() {
        if isIslandActive {
            stopLiveActivity()
        } else {
            startLiveActivity()
        }
    }

    func resetSessionStats() {
        peakDownloadSpeed = 0
        totalDownloadBytes = 0
        totalUploadBytes = 0
        downloadHistory = Array(repeating: 0, count: 30)
    }

    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            statusMessage = "请在系统“设置 → 灵动网速 → 实时活动”中开启权限。"
            return
        }

        Task {
            // End any stale activities before starting a fresh one
            for existing in Activity<NetSpeedAttributes>.activities {
                await existing.end(nil, dismissalPolicy: .immediate)
            }

            let attributes = NetSpeedAttributes(startedAt: Date())
            let state = makeContentState()
            let content = ActivityContent(
                state: state,
                staleDate: Date().addingTimeInterval(max(10, refreshInterval * 5))
            )

            do {
                let activity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                self.currentActivity = activity
                self.isIslandActive = true
                self.statusMessage = nil
                if self.enableBackgroundKeepAlive {
                    self.keepAlive.start()
                }
            } catch {
                self.statusMessage = "启动灵动岛失败：\(error.localizedDescription)"
            }
        }
    }

    func stopLiveActivity() {
        keepAlive.stop()
        isIslandActive = false

        let finalState = makeContentState()
        Task {
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            for activity in Activity<NetSpeedAttributes>.activities {
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
            self.currentActivity = nil
        }
    }

    private func syncExistingActivity() {
        if let existing = Activity<NetSpeedAttributes>.activities.first {
            currentActivity = existing
            isIslandActive = true
        }
    }

    private func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        let sample = sampler.sample()
        downloadSpeed = sample.downloadBytesPerSec
        uploadSpeed = sample.uploadBytesPerSec
        networkType = sample.networkType
        totalDownloadBytes += sample.deltaDownloadBytes
        totalUploadBytes += sample.deltaUploadBytes
        if downloadSpeed > peakDownloadSpeed {
            peakDownloadSpeed = downloadSpeed
        }

        downloadHistory.append(downloadSpeed)
        if downloadHistory.count > 30 {
            downloadHistory.removeFirst()
        }

        if let activity = currentActivity {
            let state = makeContentState()
            let staleDate = Date().addingTimeInterval(max(10, refreshInterval * 5))
            Task {
                await activity.update(ActivityContent(state: state, staleDate: staleDate))
            }
        }
    }

    private func makeContentState() -> NetSpeedAttributes.ContentState {
        NetSpeedAttributes.ContentState(
            downloadBytesPerSec: downloadSpeed,
            uploadBytesPerSec: uploadSpeed,
            totalDownloadBytes: totalDownloadBytes,
            totalUploadBytes: totalUploadBytes,
            networkType: networkType,
            updatedAt: Date()
        )
    }
}
