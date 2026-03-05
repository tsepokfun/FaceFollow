import SwiftUI
@available(iOS 17.0, *)
struct ContentView: View {
    @State private var isRecording = false
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        TabView {
            ScoreboardView(isRecording: $isRecording)
                .tabItem { Label("Scoreboard", systemImage: "chart.bar.fill") }
            
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
            
            Button(action: { isRecording = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "face.smiling.fill")
                        .font(.title)
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .frame(minWidth: 200, minHeight: 50)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .tabItem { Label("Record", systemImage: "face.smiling") }
            
            InsightsView()
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }
            
            SettingView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $isRecording) {
            NavigationStack {
                RecordView(isRecording: $isRecording)
            }
        }
    }
}
