import Darwin
import Foundation
import Network

struct NetworkSample {
    let downloadBytesPerSec: Double
    let uploadBytesPerSec: Double
    let deltaDownloadBytes: UInt64
    let deltaUploadBytes: UInt64
    let networkType: String
}

/// Reads device-wide Wi-Fi (en0) and Cellular (pdp_ip*) interface byte counters via getifaddrs.
final class NetworkSpeedSampler {
    private var previousCounters: [String: (rx: UInt32, tx: UInt32)] = [:]
    private var previousTimestamp: Date?
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.personal.netspeedisland.pathmonitor")
    private var currentNetworkType: String = "检测中"

    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status != .satisfied {
                self.currentNetworkType = "无网络"
            } else if path.usesInterfaceType(.wifi) {
                self.currentNetworkType = "Wi-Fi"
            } else if path.usesInterfaceType(.cellular) {
                self.currentNetworkType = "蜂窝网络"
            } else if path.usesInterfaceType(.wiredEthernet) {
                self.currentNetworkType = "有线网络"
            } else {
                self.currentNetworkType = "在线"
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    deinit {
        pathMonitor.cancel()
    }

    func resetBaseline() {
        previousCounters = readInterfaceCounters()
        previousTimestamp = Date()
    }

    func sample() -> NetworkSample {
        let now = Date()
        let current = readInterfaceCounters()

        guard let lastTime = previousTimestamp else {
            previousCounters = current
            previousTimestamp = now
            return NetworkSample(
                downloadBytesPerSec: 0,
                uploadBytesPerSec: 0,
                deltaDownloadBytes: 0,
                deltaUploadBytes: 0,
                networkType: currentNetworkType
            )
        }

        let elapsed = max(0.2, now.timeIntervalSince(lastTime))
        var deltaRx: UInt64 = 0
        var deltaTx: UInt64 = 0

        for (name, nowCounts) in current {
            if let oldCounts = previousCounters[name] {
                deltaRx += diffUInt32(from: oldCounts.rx, to: nowCounts.rx)
                deltaTx += diffUInt32(from: oldCounts.tx, to: nowCounts.tx)
            }
        }

        previousCounters = current
        previousTimestamp = now

        return NetworkSample(
            downloadBytesPerSec: Double(deltaRx) / elapsed,
            uploadBytesPerSec: Double(deltaTx) / elapsed,
            deltaDownloadBytes: deltaRx,
            deltaUploadBytes: deltaTx,
            networkType: currentNetworkType
        )
    }

    /// Safely handles 32-bit if_data byte counter wrap-around at 4 GiB.
    private func diffUInt32(from old: UInt32, to new: UInt32) -> UInt64 {
        if new >= old {
            return UInt64(new - old)
        } else {
            return UInt64(UInt32.max - old) + UInt64(new) + 1
        }
    }

    private func readInterfaceCounters() -> [String: (rx: UInt32, tx: UInt32)] {
        var result: [String: (rx: UInt32, tx: UInt32)] = [:]
        var ifaddrPointer: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddrPointer) == 0, let firstAddr = ifaddrPointer else {
            return result
        }
        defer { freeifaddrs(ifaddrPointer) }

        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let current = ptr {
            let interface = current.pointee
            if let addr = interface.ifa_addr,
               addr.pointee.sa_family == UInt8(AF_LINK),
               let dataPtr = interface.ifa_data {
                let name = String(cString: interface.ifa_name)
                // Count primary Wi-Fi (en0) and cellular (pdp_ip*) interfaces to avoid VPN/loopback double counting
                if name == "en0" || name.hasPrefix("pdp_ip") {
                    let networkData = dataPtr.assumingMemoryBound(to: if_data.self).pointee
                    result[name] = (rx: networkData.ifi_ibytes, tx: networkData.ifi_obytes)
                }
            }
            ptr = interface.ifa_next
        }
        return result
    }
}
