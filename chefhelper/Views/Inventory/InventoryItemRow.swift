import SwiftUI
import SwiftData

struct InventoryItemRow: View {
    @Bindable var item: InventoryItem
    let showExpiryDate: Bool
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 8) {
            Text(item.name)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.brown)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(dateFormatter.string(from: item.arrivalDate))
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.gray)
                .frame(width: 80)
            
            // Näytä VKP vain jos showExpiryDate on true ja tuote on tuoretuote
            if showExpiryDate && item.category == .fresh {
                if let expiryDate = item.expiryDate {
                    Text(dateFormatter.string(from: expiryDate))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(isExpiringSoon(date: expiryDate) ? .red : .gray)
                        .frame(width: 80)
                } else {
                    Text("-")
                        .frame(width: 80)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 4) {
                TextField(
                    "Määrä",
                    value: $item.amount,
                    format: .number
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                
                Text(item.unit.rawValue)
                    .foregroundColor(.gray)
                    .frame(width: 30)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func isExpiringSoon(date: Date) -> Bool {
        let threeDays: TimeInterval = 3 * 24 * 60 * 60
        return date.timeIntervalSinceNow < threeDays
    }
} 
