

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct SettingView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @Environment(\.modelContext) private var modelContext
    
    @State private var aboutTapCount = 0
    @State private var developerMode = false
    @State private var showClearConfirmation = false
    @State private var showGenerateConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Toggle("Dark Theme", isOn: $isDarkMode)
                Text("Language: English")
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("About")) {
                Text("Face Follow - V2.1.3")
                    .onTapGesture {
                        aboutTapCount += 1
                        if aboutTapCount >= 5 {
                            developerMode.toggle()
                            aboutTapCount = 0
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
            }
            
            if developerMode {
                Section(header: Text("Developer").foregroundColor(.orange)) {
                    Button("Clear All Data") {
                        showClearConfirmation = true
                    }
                    .foregroundColor(.red)
                    
                    Button("Generate Random Month Data") {
                        showGenerateConfirmation = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Exit Developer Mode") {
                        withAnimation {
                            developerMode = false
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .alert("Clear All Data?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all your emotion records.")
        }
        .alert("Generate Random Data?", isPresented: $showGenerateConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Generate", role: .destructive) {
                generateRandomMonthData()
            }
        } message: {
            Text("This will delete all existing records and replace them with one month of random test data.")
        }
    }
    
    private func clearAllData() {
        do {
            try modelContext.delete(model: EmotionRecord.self)
            try modelContext.save()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to clear data: \(error)")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func generateRandomMonthData() {
        clearAllData()
        
        let calendar = Calendar.current
        let today = Date()
        let emojis = ["😃", "😲", "😠", "😗", "😳"]
        let comments = [
            "Feeling great!", "Need more coffee", "Productive day",
            "A bit tired", "😴", "Awesome!", "", "😐", "Happy",
            "Stressed", "Relaxed", "Excited", "Meh", "😊"
        ]
        
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let passion = Double.random(in: 20...100)
            let energy = Double.random(in: 20...100)
            let positivity = Double.random(in: 20...100)
            let emoji = emojis.randomElement()!
            let calculated = EmotionCalculator.getWord(passion: passion, energy: energy, positivity: positivity)
            let similarity = Double.random(in: 30...95)
            let comment = comments.randomElement()!
            
            let record = EmotionRecord(
                passion: passion,
                energy: energy,
                positivity: positivity,
                calculatedEmotion: calculated,
                chosenEmoji: emoji,
                faceSimilarityScore: similarity,
                userComment: comment
            )
            record.date = date
            modelContext.insert(record)
        }
        
        do {
            try modelContext.save()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Failed to save test data: \(error)")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}
