

import SwiftUI
@available(iOS 17.0, *)

struct RecordView: View {
    @Binding var isRecording: Bool
    
    @State private var passion: Double = 50
    @State private var energy: Double = 50
    @State private var positivity: Double = 50
    
    var body: some View {
        VStack(spacing: 40) {
            Text("How do you feel?")
                .font(.title).bold()
            
            Circle()
                .fill(EmotionCalculator.getColor(passion: passion, energy: energy, positivity: positivity))
                .frame(width: 150 + (passion / 2), height: 150 + (passion / 2))
                .shadow(color: EmotionCalculator.getColor(passion: passion, energy: energy, positivity: positivity).opacity(energy/100), radius: 20)
                .animation(.easeInOut, value: passion)
            
            VStack {
                SliderRow(title: "Passion", value: $passion)
                SliderRow(title: "Energy", value: $energy)
                SliderRow(title: "Positivity", value: $positivity)
            }
            .padding()
            
            NavigationLink(destination: EmojiPickerView(isRecording: $isRecording, passion: passion, energy: energy, positivity: positivity)) {
                Text("Confirm")
                    .bold()
                    .frame(width: 200, height: 50)
                    .background(Color.primary)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .cornerRadius(25)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { isRecording = false }
            }
        }
    }
}

@available(iOS 17.0, *)
struct SliderRow: View {
    var title: String
    @Binding var value: Double
    var body: some View {
        HStack {
            Text(title).frame(width: 80, alignment: .leading)
            Slider(value: $value, in: 0...100)
        }
    }
}
