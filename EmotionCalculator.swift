
import SwiftUI
@available(iOS 17.0, *)
struct EmotionCalculator {
    static func getColor(passion: Double, energy: Double, positivity: Double) -> Color {
        let hue = positivity / 100.0 * 0.15 + 0.55
        let brightness = 0.5 + (energy / 200.0)
        return Color(hue: hue, saturation: 0.8, brightness: brightness)
    }
    
    static func getWord(passion: Double, energy: Double, positivity: Double) -> String {
        if positivity > 70 && energy > 70 { return "Joyful" }
        if positivity > 60 { return "Content" }
        if positivity < 40 && energy > 60 { return "Frustrated" }
        if positivity < 40 && energy < 40 { return "Upset" }
        if passion > 80 { return "Driven" }
        return "Neutral"
    }
}
