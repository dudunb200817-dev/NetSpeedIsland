import SwiftUI

@main
struct NetSpeedIslandApp: App {
    @StateObject private var viewModel = SpeedMonitorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
