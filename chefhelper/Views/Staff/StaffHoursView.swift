import SwiftUI
import SwiftData

struct StaffHoursView: View {
    let staff: Staff
    @State private var selectedTimeRange: TimeRange = .week
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Date()
    @State private var showingOverworkAlert = false
    @State private var overworkMessage = ""
    @State private var pendingShift: WorkShift?
    
    enum TimeRange: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
        case custom = "custom_range"
        
        var localizedName: String {
            return rawValue.localized
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("time_range".localized)) {
                Picker("select_range".localized, selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.localizedName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                
                if selectedTimeRange == .custom {
                    DatePicker("start_date".localized, selection: $customStartDate, displayedComponents: .date)
                    DatePicker("end_date".localized, selection: $customEndDate, displayedComponents: .date)
                }
            }
            
            Section(header: Text("past_hours".localized)) {
                let pastHours = calculateHours(isPast: true)
                if pastHours.isEmpty {
                    Text("no_past_hours".localized)
                        .foregroundColor(.gray)
                } else {
                    ForEach(pastHours, id: \.0) { week, hours in
                        HStack {
                            Text("week".localized + " \(week)")
                            Spacer()
                            Text(String(format: "%.1f h", hours))
                        }
                    }
                }
            }
            
            Section(header: Text("upcoming_hours".localized)) {
                let upcomingHours = calculateHours(isPast: false)
                if upcomingHours.isEmpty {
                    Text("no_upcoming_hours".localized)
                        .foregroundColor(.gray)
                } else {
                    ForEach(upcomingHours, id: \.0) { week, hours in
                        HStack {
                            Text("week".localized + " \(week)")
                            Spacer()
                            Text(String(format: "%.1f h", hours))
                                .foregroundColor(hours > 37.5 ? .red : .primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("\(staff.name) - \("hours".localized)")
        .alert("overwork_warning".localized, isPresented: $showingOverworkAlert) {
            Button("cancel".localized, role: .cancel) { }
            Button("confirm".localized) {
                if let shift = pendingShift {
                    staff.schedule.append(shift)
                    pendingShift = nil
                }
            }
        } message: {
            Text(overworkMessage)
        }
    }
    
    private func calculateHours(isPast: Bool) -> [(Int, Double)] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        let endDate: Date
        
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            endDate = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            endDate = calendar.date(byAdding: .month, value: 1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            endDate = calendar.date(byAdding: .year, value: 1, to: now) ?? now
        case .custom:
            startDate = customStartDate
            endDate = customEndDate
        }
        
        let shifts = staff.schedule.filter { shift in
            let isPastShift = shift.date < now
            return isPastShift == isPast && shift.date >= startDate && shift.date <= endDate
        }
        
        var weeklyHours: [Int: Double] = [:]
        
        for shift in shifts {
            let weekNumber = calendar.component(.weekOfYear, from: shift.date)
            let hours = calendar.dateComponents([.hour], from: shift.startTime, to: shift.endTime).hour ?? 0
            weeklyHours[weekNumber, default: 0] += Double(hours)
        }
        
        return weeklyHours.sorted { $0.key < $1.key }
    }
    
    func checkOverwork(for shift: WorkShift) -> Bool {
        let calendar = Calendar.current
        let shiftHours = Double(calendar.dateComponents([.hour], from: shift.startTime, to: shift.endTime).hour ?? 0)
        
        // Tarkista viikkotunnit
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: shift.date)) ?? shift.date
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? shift.date
        
        let weeklyShifts = staff.schedule.filter { $0.date >= weekStart && $0.date < weekEnd }
        let weeklyHours = weeklyShifts.reduce(0.0) { sum, shift in
            sum + Double(calendar.dateComponents([.hour], from: shift.startTime, to: shift.endTime).hour ?? 0)
        } + shiftHours
        
        if weeklyHours > 37.5 {
            overworkMessage = "weekly_hours_exceeded".localized
            showingOverworkAlert = true
            pendingShift = shift
            return true
        }
        
        // Tarkista 4 viikon tunnit
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: shift.date) ?? shift.date
        let fourWeekShifts = staff.schedule.filter { $0.date >= fourWeeksAgo && $0.date <= shift.date }
        let fourWeekHours = fourWeekShifts.reduce(0.0) { sum, shift in
            sum + Double(calendar.dateComponents([.hour], from: shift.startTime, to: shift.endTime).hour ?? 0)
        } + shiftHours
        
        if fourWeekHours > 150.0 {
            overworkMessage = "four_week_hours_exceeded".localized
            showingOverworkAlert = true
            pendingShift = shift
            return true
        }
        
        return false
    }
} 