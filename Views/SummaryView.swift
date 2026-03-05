import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isRecording: Bool
    
    var passion: Double
    var energy: Double
    var positivity: Double
    var chosenEmoji: String
    var similarityScore: Double
    
    @State private var comment: String = ""
    @State private var randomSlogan: String = ""
    
    let slogans = [
        "Your face, your rules. Every emotion is valid.",
        "Understanding yourself is the first step to being understood.",
        "There's no 'wrong' face for how you feel.",
        "Thank you for taking a moment to check in with yourself.",
        "Your feelings matter. Your expressions belong to you.",
        "Communication starts from within. Great job today!",
        "Whether you smile or pout, your emotions are real and valid."
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Analysis Complete")
                .font(.largeTitle).bold()
            
            Text("Your Emotion:")
            Text(EmotionCalculator.getWord(passion: passion, energy: energy, positivity: positivity))
                .font(.title)
                .foregroundColor(EmotionCalculator.getColor(passion: passion, energy: energy, positivity: positivity))
            
            Text("Mask Similarity: \(Int(similarityScore))%")
                .font(.headline)
            
            TextField("Leave a comment (Optional)", text: $comment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text(randomSlogan)
                .font(.subheadline)
                .italic()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
            
            Button(action: saveAndClose) {
                Text("Save")
                    .bold()
                    .frame(width: 200, height: 50)
                    .background(Color.primary)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .cornerRadius(25)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            randomSlogan = slogans.randomElement() ?? slogans[0]
        }
    }
    
    func saveAndClose() {
        let word = EmotionCalculator.getWord(passion: passion, energy: energy, positivity: positivity)
        let record = EmotionRecord(passion: passion, energy: energy, positivity: positivity, calculatedEmotion: word, chosenEmoji: chosenEmoji, faceSimilarityScore: similarityScore, userComment: comment)
        
        modelContext.insert(record)
        isRecording = false
    }
}
