

import SwiftUI
@available(iOS 17.0, *)
struct EmojiPickerView: View {
    @Binding var isRecording: Bool
    var passion: Double
    var energy: Double
    var positivity: Double
    
    let challenges = EmojiChallenge.library
    
    let columns = [GridItem(.adaptive(minimum: 140))]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select a Mask")
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                Text("Choose the face you want to try and mimic.")
                    .foregroundColor(.gray)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(challenges, id: \.emoji) { challenge in
                        NavigationLink(destination: FaceSimulationView(isRecording: $isRecording, passion: passion, energy: energy, positivity: positivity, chosenEmoji: challenge.emoji)) {
                            VStack {
                                Text(challenge.emoji)
                                    .font(.system(size: 80))
                                
                                Text(challenge.targetEmotion)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(challenge.instruction)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.vertical, 30)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
