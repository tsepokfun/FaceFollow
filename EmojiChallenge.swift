import Foundation

enum FacialFeature {
    case smile
    case pout
    case browsUp
    case browsDown
    case eyesWide
}
@available(iOS 17.0, *)
struct EmojiChallenge {
    let emoji: String
    let targetEmotion: String
    let instruction: String
    let featureToTrack: FacialFeature
    
    static let library: [EmojiChallenge] = [
        EmojiChallenge(
            emoji: "😃",
            targetEmotion: "Joy",
            instruction: "Smile as wide as you can! 😁",
            featureToTrack: .smile
        ),
        EmojiChallenge(
            emoji: "😲",
            targetEmotion: "Surprise",
            instruction: "Raise your eyebrows high! 😲",
            featureToTrack: .browsUp
        ),
        EmojiChallenge(
            emoji: "😠",
            targetEmotion: "Anger",
            instruction: "Furrow your eyebrows downward! 😠",
            featureToTrack: .browsDown
        ),
        EmojiChallenge(
            emoji: "😗",
            targetEmotion: "Playful",
            instruction: "Pout your lips together! 😗",
            featureToTrack: .pout
        ),
        EmojiChallenge(
            emoji: "😳",
            targetEmotion: "Shock",
            instruction: "Open your eyes super wide! 😳",
            featureToTrack: .eyesWide
        )
    ]
    
    static func get(for emoji: String) -> EmojiChallenge {
        return library.first(where: { $0.emoji == emoji }) ?? library[0]
    }
}
