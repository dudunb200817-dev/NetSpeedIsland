import ActivityKit
import Foundation

public struct NetSpeedAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var downloadBytesPerSec: Double
        public var uploadBytesPerSec: Double
        public var totalDownloadBytes: UInt64
        public var totalUploadBytes: UInt64
        public var networkType: String
        public var updatedAt: Date

        public init(
            downloadBytesPerSec: Double,
            uploadBytesPerSec: Double,
            totalDownloadBytes: UInt64,
            totalUploadBytes: UInt64,
            networkType: String,
            updatedAt: Date = Date()
        ) {
            self.downloadBytesPerSec = downloadBytesPerSec
            self.uploadBytesPerSec = uploadBytesPerSec
            self.totalDownloadBytes = totalDownloadBytes
            self.totalUploadBytes = totalUploadBytes
            self.networkType = networkType
            self.updatedAt = updatedAt
        }
    }

    public var startedAt: Date

    public init(startedAt: Date = Date()) {
        self.startedAt = startedAt
    }
}

public enum SpeedFormatter {
    /// Full readable format, e.g. "12.4 MB/s" or "320 KB/s"
    public static func formatSpeed(_ bytesPerSec: Double) -> String {
        let safe = max(0, bytesPerSec)
        if safe < 1024 {
            return String(format: "%.0f B/s", safe)
        } else if safe < 1024 * 1024 {
            let kb = safe / 1024.0
            return kb >= 100 ? String(format: "%.0f KB/s", kb) : String(format: "%.1f KB/s", kb)
        } else if safe < 1024 * 1024 * 1024 {
            let mb = safe / (1024.0 * 1024.0)
            return mb >= 100 ? String(format: "%.0f MB/s", mb) : String(format: "%.1f MB/s", mb)
        } else {
            let gb = safe / (1024.0 * 1024.0 * 1024.0)
            return String(format: "%.2f GB/s", gb)
        }
    }

    /// Compact format designed to fit cleanly inside Dynamic Island compact slots
    public static func formatCompactSpeed(_ bytesPerSec: Double) -> String {
        let safe = max(0, bytesPerSec)
        if safe < 1024 {
            return String(format: "%.0fB", safe)
        } else if safe < 1024 * 1024 {
            let kb = safe / 1024.0
            return kb >= 100 ? String(format: "%.0fK", kb) : String(format: "%.1fK", kb)
        } else if safe < 1024 * 1024 * 1024 {
            let mb = safe / (1024.0 * 1024.0)
            return mb >= 100 ? String(format: "%.0fM", mb) : String(format: "%.1fM", mb)
        } else {
            let gb = safe / (1024.0 * 1024.0 * 1024.0)
            return String(format: "%.1fG", gb)
        }
    }

    /// Cumulative data size format, e.g. "128.5 MB"
    public static func formatBytes(_ bytes: UInt64) -> String {
        let val = Double(bytes)
        if val < 1024 {
            return "\(bytes) B"
        } else if val < 1024 * 1024 {
            return String(format: "%.1f KB", val / 1024.0)
        } else if val < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", val / (1024.0 * 1024.0))
        } else {
            return String(format: "%.2f GB", val / (1024.0 * 1024.0 * 1024.0))
        }
    }
}
