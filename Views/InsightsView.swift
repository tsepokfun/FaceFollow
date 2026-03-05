
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let icon: String
    let color: Color
}

@available(iOS 17.0, *)
struct InsightsView: View {
    @Query(sort: \EmotionRecord.date, order: .reverse) var records: [EmotionRecord]
    
    var generatedInsights: [Insight] {
        var insights: [Insight] = []
        
        guard records.count >= 3 else {
            return[Insight(title: "Keep Going!", message: "Record your emotions a few more times. We need a bit more data to unlock personalized insights about your unique expressions.", icon: "lock.open.fill", color: .gray)]
        }
        
        let avgPositivity = records.map(\.positivity).reduce(0, +) / Double(records.count)
        let avgSimilarity = records.map(\.faceSimilarityScore).reduce(0, +) / Double(records.count)
        
        let upsetMasks = records.filter { $0.chosenEmoji == "😠" || $0.chosenEmoji == "😳" }
        
        if avgPositivity > 50 && upsetMasks.count >= (records.count / 3) {
            insights.append(Insight(
                title: "The 'Resting Face' Reality",
                message: "We noticed you often feel quite positive inside, but select intense masks like 😠. Remember: there's no 'wrong' resting face. If you are happy, you don't always have to perform a giant smile for the world. Your natural expression is perfectly valid!",
                icon: "face.smiling.inverse",
                color: .purple
            ))
        } else if avgPositivity > 70 {
            insights.append(Insight(
                title: "Glowing From Within",
                message: "Your inner positivity is shining bright! Holding onto this good energy is wonderful. Keep taking moments to check in with yourself.",
                icon: "sun.max.fill",
                color: .orange
            ))
        } else if avgPositivity < 40 {
            insights.append(Insight(
                title: "Gentle Reminder",
                message: "It looks like you've been having a tough time recently. Remember that all emotions are valid. It's okay not to be okay, and taking it one step at a time is perfectly fine.",
                icon: "heart.fill",
                color: .red
            ))
        }
        
        if avgSimilarity < 60 {
            insights.append(Insight(
                title: "Beautifully Unique",
                message: "Your face doesn't always strictly match the 'standard' emoji shapes—and that is beautiful! Your expressions are influenced by your background, habits, and life. Keep embracing your own way of showing emotion.",
                icon: "star.fill",
                color: .blue
            ))
        } else {
            insights.append(Insight(
                title: "Strong Mind-Muscle Connection",
                message: "Your expressions match the target masks very closely. You have great control over your facial muscles! Keep using this to communicate your inner feelings effectively.",
                icon: "checkmark.seal.fill",
                color: .green
            ))
        }
        
        insights.append(Insight(
            title: "Communication is Key",
            message: "By recording your feelings, you are practicing the most important communication: the one with yourself. Keep giving your emotions the space they deserve.",
            icon: "heart.text.square.fill",
            color: .pink
        ))
        
        return insights
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Understanding your unique emotional language. Let's see what your data says about you.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(generatedInsights) { insight in
                        InsightCardView(insight: insight)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
        }
    }
}

@available(iOS 17.0, *)
struct InsightCardView: View {
    let insight: Insight
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: insight.icon)
                .font(.system(size: 30))
                .foregroundColor(insight.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
