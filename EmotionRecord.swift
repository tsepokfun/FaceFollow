
import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
class EmotionRecord {
    var id: UUID
    var date: Date
    var passion: Double
    var energy: Double
    var positivity: Double
    var calculatedEmotion: String
    var chosenEmoji: String
    var faceSimilarityScore: Double
    var userComment: String
    
    init(passion: Double, energy: Double, positivity: Double, calculatedEmotion: String, chosenEmoji: String, faceSimilarityScore: Double, userComment: String = "") {
        self.id = UUID()
        self.date = Date()
        self.passion = passion
        self.energy = energy
        self.positivity = positivity
        self.calculatedEmotion = calculatedEmotion
        self.chosenEmoji = chosenEmoji
        self.faceSimilarityScore = faceSimilarityScore
        self.userComment = userComment
    }
}
