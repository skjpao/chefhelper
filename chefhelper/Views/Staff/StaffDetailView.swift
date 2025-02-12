import SwiftUI
import SwiftData

struct StaffDetailView: View {
    let staff: Staff
    
    var body: some View {
        List {
            Section(header: Text("hours".localized)) {
                NavigationLink(destination: StaffHoursView(staff: staff)) {
                    Label("view_hours".localized, systemImage: "clock")
                }
            }
        }
    }
} 