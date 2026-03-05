

import SwiftUI
import SwiftData
import Charts

@available(iOS 17.0, *)
struct ScoreboardView: View {
    @State private var headerSlogan: String = "Emotional Patterns"
    let headerSlogans = [
        "Every expression tells a story.",
        "Embrace your unique way of feeling.",
        "Tracking your journey, one face at a time.",
        "Your feelings, your canvas.",
        "There's no wrong way to express yourself."
    ]
    @Binding var isRecording: Bool
    @Query(sort: \EmotionRecord.date, order: .reverse) var records: [EmotionRecord]
    
    var currentStreak: Int {
        guard !records.isEmpty else { return 0 }
        var streak = 1
        let calendar = Calendar.current
        for i in 0..<(records.count - 1) {
            if calendar.isDate(records[i].date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: records[i+1].date)!) {
                streak += 1
            } else if !calendar.isDate(records[i].date, inSameDayAs: records[i+1].date) {
                break
            }
        }
        return streak
    }
    
    var averageScoresPerEmoji: [(emoji: String, passion: Double, energy: Double, positivity: Double)] {
        let grouped = Dictionary(grouping: records, by: { $0.chosenEmoji })
        return grouped.map { (emoji, records) in
            let count = Double(records.count)
            let avgPassion = records.reduce(0) { $0 + $1.passion } / count
            let avgEnergy = records.reduce(0) { $0 + $1.energy } / count
            let avgPositivity = records.reduce(0) { $0 + $1.positivity } / count
            return (emoji, avgPassion, avgEnergy, avgPositivity)
        }.sorted { $0.emoji < $1.emoji }
    }
    
    var chartData: [(emoji: String, metric: String, value: Double)] {
        averageScoresPerEmoji.flatMap { item in
            [
                (item.emoji, "Passion", item.passion),
                (item.emoji, "Energy", item.energy),
                (item.emoji, "Positivity", item.positivity)
            ]
        }
    }
    
    var trendData: [(date: Date, metric: String, value: Double)] {
        let last7 = Array(records.prefix(7).reversed())
        return last7.flatMap { record in
            [
                (record.date, "Passion", record.passion),
                (record.date, "Energy", record.energy),
                (record.date, "Positivity", record.positivity)
            ]
        }
    }
    
    var emojiFrequencyData: [(emoji: String, count: Int)] {
        let last7 = Array(records.prefix(7))
        let grouped = Dictionary(grouping: last7, by: { $0.chosenEmoji })
        return grouped.map { (emoji, records) in
            (emoji, records.count)
        }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Scoreboard").font(.largeTitle).bold()
                            Text(headerSlogan)
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .italic()
                        }
                        Spacer()
                        VStack {
                            Text("🔥").font(.title)
                            Text("\(currentStreak) Days").font(.caption).bold()
                        }
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .onAppear {
                        headerSlogan = headerSlogans.randomElement() ?? "Emotional Patterns"
                    }
                    if !trendData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("7‑Day Emotion Trends").font(.headline)
                            Chart {
                                ForEach(trendData, id: \.metric) { item in
                                    LineMark(
                                        x: .value("Date", item.date, unit: .day),
                                        y: .value("Score", item.value)
                                    )
                                    .foregroundStyle(by: .value("Metric", item.metric))
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol(by: .value("Metric", item.metric))
                                }
                            }
                            .frame(height: 200)
                            .chartForegroundStyleScale([
                                "Passion": .orange,
                                "Energy": .yellow,
                                "Positivity": .green
                            ])
                            .chartSymbolScale([
                                "Passion": Circle().strokeBorder(lineWidth: 2),
                                "Energy": Circle().strokeBorder(lineWidth: 2),
                                "Positivity": Circle().strokeBorder(lineWidth: 2)
                            ])
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    if let date = value.as(Date.self) {
                                        AxisValueLabel {
                                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    if !chartData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Emotion vs. Chosen Mask").font(.headline)
                            Chart(chartData, id: \.emoji) { item in
                                BarMark(
                                    x: .value("Emoji", item.emoji),
                                    y: .value("Score", item.value)
                                )
                                .foregroundStyle(by: .value("Metric", item.metric))
                                .position(by: .value("Metric", item.metric))
                            }
                            .frame(height: 200)
                            .chartForegroundStyleScale([
                                "Passion": .orange,
                                "Energy": .yellow,
                                "Positivity": .green
                            ])
                            .chartLegend(position: .bottom)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    if !emojiFrequencyData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Masks Used This Week").font(.headline)
                            Chart(emojiFrequencyData, id: \.emoji) { item in
                                BarMark(
                                    x: .value("Count", item.count),
                                    y: .value("Emoji", item.emoji)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                            .frame(height: CGFloat(emojiFrequencyData.count * 40))
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                    AxisGridLine()
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    if !records.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Logs").font(.headline).padding(.horizontal)
                            
                            TabView {
                                ForEach(records.prefix(5)) { record in
                                    ExpandableRecordCard(record: record)
                                        .padding(.horizontal)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .frame(height: 260)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("No records yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Start your journey by recording your first emotion")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.bottom, 100)
            }
            .overlay(
                Button(action: { isRecording = true }) {
                    HStack {
                        Image(systemName: "face.smiling.fill")
                        Text("Record NOW")
                    }
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .padding()
                    .frame(width: 250, height: 60)
                    .background(Color.primary)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                }
                    .padding(.bottom, 20),
                alignment: .bottom
            )
        }
    }
}

@available(iOS 17.0, *)
struct ExpandableRecordCard: View {
    var record: EmotionRecord
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(record.chosenEmoji).font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text(record.calculatedEmotion)
                        .font(.title2).bold()
                        .foregroundColor(EmotionCalculator.getColor(passion: record.passion, energy: record.energy, positivity: record.positivity))
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption).foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    Circle().trim(from: 0, to: CGFloat(record.faceSimilarityScore / 100.0))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(record.faceSimilarityScore))%")
                        .font(.caption2).bold()
                }
                .frame(width: 40, height: 40)
            }
            if !record.userComment.isEmpty {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\"\(record.userComment)\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gray)
                        .lineLimit(isExpanded ? nil : 2)
                }
                .padding(.top, 2)
            }
            
            if isExpanded {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Circle().fill(.orange).frame(width: 8, height: 8)
                            Text("Passion: \(Int(record.passion))").font(.caption)
                        }
                        HStack {
                            Circle().fill(.yellow).frame(width: 8, height: 8)
                            Text("Energy: \(Int(record.energy))").font(.caption)
                        }
                        HStack {
                            Circle().fill(.green).frame(width: 8, height: 8)
                            Text("Positivity: \(Int(record.positivity))").font(.caption)
                        }
                    }
                    Spacer()
                    Text("Tap to collapse")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                HStack {
                    Spacer()
                    Text("Tap to expand")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}
