import SwiftUI

struct StaffRowView: View {
    let person: Staff
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(person.name)
                .font(.headline)
                .foregroundColor(.brown)
            Text(person.role.localized)
                .font(.subheadline)
                .foregroundColor(.gray)
            if !person.schedule.isEmpty {
                Text("shifts_count".localized + ": \(person.schedule.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 
