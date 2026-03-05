import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct CalendarView: View {
    @Query(sort: \EmotionRecord.date, order: .reverse) var records: [EmotionRecord]
    
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var dailyRecords: [EmotionRecord] {
        records.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if horizontalSizeClass == .regular {
                    HStack(alignment: .top, spacing: 30) {
                        VStack {
                            NativeCalendar(records: records, selectedDate: $selectedDate)
                                .frame(maxWidth: 450)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(20)
                            Spacer()
                        }
                        
                        Divider()
                        
                        ipadListSection
                    }
                    .padding(30)
                }
                else {
                    ScrollView {
                        VStack(spacing: 25) {
                            NativeCalendar(records: records, selectedDate: $selectedDate)
                            Divider()
                            iphoneListSection
                        }
                        .frame(maxWidth: 400)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    var iphoneListSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.title3).bold()
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            if dailyRecords.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No emotions recorded on this day.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
            } else {
                ForEach(dailyRecords) { record in
                    DailyRecordRow(record: record)
                        .padding(15)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal, 15)
                }
            }
        }
    }
    
    var ipadListSection: some View {
        VStack(alignment: .leading) {
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.title2).bold()
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top)
            
            if dailyRecords.isEmpty {
                Spacer()
                VStack(spacing: 15) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No emotions recorded on this day.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(dailyRecords) { record in
                    DailyRecordRow(record: record)
                }
                .listStyle(.plain)
            }
        }
    }
}

@available(iOS 17.0, *)
struct DailyRecordRow: View {
    var record: EmotionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(record.chosenEmoji).font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text(record.calculatedEmotion).font(.headline)
                    Text(record.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption).foregroundColor(.gray)
                }
                Spacer()
                Circle()
                    .fill(EmotionCalculator.getColor(passion: record.passion, energy: record.energy, positivity: record.positivity))
                    .frame(width: 25, height: 25)
            }
            
            HStack(spacing: 15) {
                HStack {
                    Label("Positivity", systemImage: "arrow.up.heart").font(.caption2)
                    ProgressView(value: record.positivity, total: 100).tint(.green)
                }
                HStack {
                    Label("Energy", systemImage: "bolt.fill").font(.caption2)
                    ProgressView(value: record.energy, total: 100).tint(.yellow)
                }
            }
            
            if !record.userComment.isEmpty {
                Text("💬 \"\(record.userComment)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

@available(iOS 17.0, *)
struct NativeCalendar: UIViewRepresentable {
    var records: [EmotionRecord]
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar.current
        view.locale = Locale.current
        view.fontDesign = .rounded
        view.delegate = context.coordinator
        
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        view.selectionBehavior = selection
        
        return view
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        let dateComponents = records.map { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) }
        uiView.reloadDecorations(forDateComponents: dateComponents, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: NativeCalendar
        
        init(_ parent: NativeCalendar) {
            self.parent = parent
        }
        
        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let dailyRecords = parent.records.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            guard let firstRecord = dailyRecords.last else { return nil }
            
            return .customView {
                let label = UILabel()
                label.text = firstRecord.chosenEmoji
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                return label
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            if let dateComponents = dateComponents, let date = Calendar.current.date(from: dateComponents) {
                DispatchQueue.main.async {
                    self.parent.selectedDate = date
                }
            }
        }
    }
}
