
import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct FaceFollowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.primary)
        }
        .modelContainer(for: EmotionRecord.self)
    }
}
