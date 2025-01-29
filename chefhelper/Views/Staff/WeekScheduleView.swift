import SwiftUI

struct WeekScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedWeek: Date
    let staff: [Staff]
    @State private var selectedDate: Date?
    @State private var showingMonthPicker = false
    
    private let weekDays = ["monday_short".localized, "tuesday_short".localized, 
                           "wednesday_short".localized, "thursday_short".localized, 
                           "friday_short".localized, "saturday_short".localized, 
                           "sunday_short".localized]
    private let timeSlots = Array(6...24)
    private let visibleTimeSlots = Array(9...22) // Default visible hours
    
    private var weekNumber: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: selectedWeek)
        return components.weekOfYear ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week navigation with week number
            HStack(spacing: 16) {
                // Viikkonumero
                Text("\("week".localized) \(weekNumber)")
                    .font(.headline)
                    .foregroundColor(.brown)
                    .padding(.leading)
                
                // Week navigation
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.brown)
                    }
                    
                    Button(action: { showingMonthPicker = true }) {
                        Text(weekString(from: selectedWeek))
                            .font(.headline)
                            .foregroundColor(.brown)
                    }
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.brown)
                    }
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)
            
            // Kalenteri
            ScrollView(.horizontal, showsIndicators: false) {
                VStack {
                    // Header row with dates
                    HStack(alignment: .top, spacing: 1) {
                        // Time column
                        VStack(alignment: .leading) {
                            Text("time".localized)
                                .font(.caption.bold())
                                .frame(width: 50)
                        }
                        
                        // Day columns
                        ForEach(weekDays, id: \.self) { day in
                            if let date = getDate(for: day) {
                                VStack {
                                    Text(day)
                                        .font(.caption.bold())
                                    Text(formatDate(date))
                                        .font(.caption)
                                }
                                .frame(width: 120)
                                .padding(.vertical, 4)
                                .background(Color.brown.opacity(0.1))
                            }
                        }
                    }
                    
                    // Time slots with shifts
                    ScrollView(.vertical, showsIndicators: true) {
                        ZStack {
                            // Tuntien ruudukko -> Hours grid
                            VStack(spacing: 1) {
                                ForEach(timeSlots, id: \.self) { hour in
                                    HStack(spacing: 1) {
                                        Text("\(hour):00")
                                            .font(.caption)
                                            .frame(width: 50)
                                        
                                        ForEach(weekDays, id: \.self) { day in
                                            Color.gray.opacity(0.1)
                                                .frame(width: 120, height: 30)
                                        }
                                    }
                                }
                            }
                            
                            // Vuorot päällekkäin ruudukon kanssa -> Shifts overlaid on grid
                            HStack(spacing: 1) {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 50)
                                
                                ForEach(weekDays, id: \.self) { day in
                                    if let date = getDate(for: day) {
                                        DayShifts(date: date, staff: staff)
                                            .frame(width: 120)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    .onAppear {
                        // Scroll to default visible hours on appear
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let scrollView = findScrollView() {
                                let offset = CGFloat(9) * 31 // Approximate height per hour
                                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMonthPicker) {
            MonthCalendarView(selectedWeek: $selectedWeek)
        }
    }
    
    private func findScrollView() -> UIScrollView? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return nil }
        
        return findScrollView(in: window)
    }
    
    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let scrollView = findScrollView(in: subview) {
                return scrollView
            }
        }
        return nil
    }
    
    private func getShifts(for date: Date, at hour: Int) -> [WorkShift] {
        let calendar = Calendar.current
        return staff.flatMap { person in
            person.schedule.filter { shift in
                let shiftDate = calendar.startOfDay(for: shift.date)
                let compareDate = calendar.startOfDay(for: date)
                
                // Tarkista että on sama päivä
                guard shiftDate == compareDate else { return false }
                
                // Tarkista onko vuoro käynnissä tällä tunnilla
                let shiftStartHour = calendar.component(.hour, from: shift.startTime)
                let shiftEndHour = calendar.component(.hour, from: shift.endTime)
                
                return hour >= shiftStartHour && hour < shiftEndHour
            }
        }
    }
    
    private func getDate(for day: String) -> Date? {
        let calendar = Calendar.current
        let weekday = weekDays.firstIndex(of: day) ?? 0
        return calendar.date(byAdding: .day, value: weekday, to: getStartOfWeek())
    }
    
    private func getStartOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedWeek)
        return calendar.date(from: components) ?? selectedWeek
    }
    
    private func weekString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M.yyyy"
        formatter.locale = Locale(identifier: "fi_FI")
        
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date)!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: weekInterval.start)!
        
        return "\(formatter.string(from: weekInterval.start)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func previousWeek() {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeek) {
            selectedWeek = newDate
        }
    }
    
    private func nextWeek() {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeek) {
            selectedWeek = newDate
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M.yyyy"
        formatter.locale = Locale(identifier: "fi_FI")
        return formatter.string(from: date)
    }
}

struct DayShifts: View {
    let date: Date
    let staff: [Staff]
    
    var body: some View {
        let shifts = getShiftsForDay()
        
        ZStack {
            ForEach(Array(shifts.enumerated()), id: \.element.0.id) { index, shiftPair in
                ShiftBar(
                    shift: shiftPair.0,
                    staffMember: shiftPair.1,
                    totalShifts: shifts.count,
                    shiftIndex: index,
                    totalHours: 24
                )
            }
        }
    }
    
    private func getShiftsForDay() -> [(WorkShift, Staff)] {
        let calendar = Calendar.current
        return staff.flatMap { staffMember in
            staffMember.schedule.compactMap { shift in
                let shiftDate = calendar.startOfDay(for: shift.date)
                let compareDate = calendar.startOfDay(for: date)
                return shiftDate == compareDate ? (shift, staffMember) : nil
            }
        }
    }
}

struct ShiftBar: View {
    let shift: WorkShift
    let staffMember: Staff
    let totalShifts: Int
    let shiftIndex: Int
    let totalHours: Int
    
    var body: some View {
        let (yPosition, height) = calculatePosition()
        let barWidth: CGFloat = totalShifts > 1 ? 58 : 118
        let xPosition: CGFloat = totalShifts > 1 ? CGFloat(58 * shiftIndex + 30) : 60
        
        ZStack(alignment: .topLeading) {
            // Taustapalkki
            Rectangle()
                .fill(Color(hex: staffMember.color).opacity(0.7))
                .frame(width: barWidth, height: height)
                .position(x: xPosition, y: yPosition)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Tekstipalkki
            VStack(alignment: .leading, spacing: 0) {
                // Nimi
                Text(staffMember.name)
                    .font(.system(size: 8))
                    .padding(2)
                    .frame(width: barWidth, alignment: .leading)
                    .background(Color.black.opacity(0.2))
                
                Spacer()
                
                // Rooli ja aika
                VStack(alignment: .leading, spacing: 0) {
                    Text(shift.position)
                        .font(.system(size: 7))
                        .padding(2)
                        .frame(width: barWidth, alignment: .leading)
                        .background(Color.black.opacity(0.2))
                    
                    Text("\(formatTime(shift.startTime))-\(formatTime(shift.endTime))")
                        .font(.system(size: 7))
                        .padding(2)
                        .frame(width: barWidth, alignment: .leading)
                        .background(Color.black.opacity(0.2))
                }
            }
            .foregroundColor(.white)
            .frame(width: barWidth, height: height)
            .position(x: xPosition, y: yPosition)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
    
    private func calculatePosition() -> (CGFloat, CGFloat) {
        let calendar = Calendar.current
        let startHour = CGFloat(calendar.component(.hour, from: shift.startTime))
        let startMinute = CGFloat(calendar.component(.minute, from: shift.startTime))
        let endHour = CGFloat(calendar.component(.hour, from: shift.endTime))
        let endMinute = CGFloat(calendar.component(.minute, from: shift.endTime))
        
        let cellHeight: CGFloat = 30
        
        let startY = (startHour + startMinute / 60.0) * cellHeight
        let endY = (endHour + endMinute / 60.0) * cellHeight
        
        let height = endY - startY
        let yPosition = startY + height / 2
        
        return (yPosition, height)
    }
}
