import SwiftUI

struct MonthCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedWeek: Date
    @State private var selectedMonth: Date
    
    init(selectedWeek: Binding<Date>) {
        self._selectedWeek = selectedWeek
        self._selectedMonth = State(initialValue: selectedWeek.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Month navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(monthYearString(from: selectedMonth))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // Week day headers
                HStack {
                    ForEach([
                        "monday_short".localized,
                        "tuesday_short".localized,
                        "wednesday_short".localized,
                        "thursday_short".localized,
                        "friday_short".localized,
                        "saturday_short".localized,
                        "sunday_short".localized
                    ], id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .font(.caption.bold())
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            let isSelected = isInSelectedWeek(date)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(isSelected ? Color.brown : Color.clear)
                                .foregroundColor(isSelected ? .white : .primary)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectWeek(containing: date)
                                }
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("select_week".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: SettingsManager.shared.selectedLanguage.rawValue)
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    private func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get start of the month
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let monthStart = interval.start
        
        // Get the first day of the month's weekday number (1-7, 1 is Monday)
        var weekday = calendar.component(.weekday, from: monthStart)
        // Convert Sunday from 1 to 7
        weekday = weekday == 1 ? 7 : weekday - 1
        
        // Create array of dates
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        
        let monthRange = calendar.range(of: .day, in: .month, for: selectedMonth)!
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        // Fill the rest of the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func isInSelectedWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let selectedWeekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedWeek)!
        return calendar.isDate(date, equalTo: selectedWeekInterval.start, toGranularity: .weekOfYear)
    }
    
    private func selectWeek(containing date: Date) {
        selectedWeek = date
        dismiss()
    }
} 
