import AVFoundation
import Foundation

/// Plays an in-memory silent WAV loop with `.mixWithOthers` so iOS keeps the app
/// alive in the background to push real-time speed updates to the Dynamic Island
/// without interrupting music, podcasts, or videos.
final class SilentAudioKeepAlive {
    private var player: AVAudioPlayer?
    private(set) var isRunning = false

    func start() {
        guard !isRunning else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let wavData = Self.makeSilentWavData(durationSeconds: 1, sampleRate: 8000)
            let audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = 0.0
            audioPlayer.prepareToPlay()
            audioPlayer.play()

            self.player = audioPlayer
            self.isRunning = true
        } catch {
            print("[SilentAudioKeepAlive] Failed to start: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isRunning = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Generates a valid 16-bit mono PCM silent WAV payload in memory.
    private static func makeSilentWavData(durationSeconds: Int, sampleRate: Int) -> Data {
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let numSamples = durationSeconds * sampleRate
        let subchunk2Size = UInt32(numSamples * Int(numChannels) * Int(bitsPerSample / 8))
        let chunkSize = UInt32(36) + subchunk2Size
        let byteRate = UInt32(sampleRate) * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * (bitsPerSample / 8)

        var data = Data()
        data.append(contentsOf: "RIFF".utf8)
        data.append(littleEndian: chunkSize)
        data.append(contentsOf: "WAVE".utf8)
        data.append(contentsOf: "fmt ".utf8)
        data.append(littleEndian: UInt32(16))
        data.append(littleEndian: UInt16(1)) // PCM
        data.append(littleEndian: numChannels)
        data.append(littleEndian: UInt32(sampleRate))
        data.append(littleEndian: byteRate)
        data.append(littleEndian: blockAlign)
        data.append(littleEndian: bitsPerSample)
        data.append(contentsOf: "data".utf8)
        data.append(littleEndian: subchunk2Size)
        data.append(Data(count: Int(subchunk2Size)))
        return data
    }
}

private extension Data {
    mutating func append<T: FixedWidthInteger>(littleEndian value: T) {
        var le = value.littleEndian
        Swift.withUnsafeBytes(of: &le) { append(contentsOf: $0) }
    }
}
