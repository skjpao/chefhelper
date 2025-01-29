import SwiftUI
import SwiftData

struct InventoryItemRow: View {
    let item: InventoryItem
    
    private var expirationColor: Color {
        guard let days = item.daysUntilExpiration else { return .gray }
        if days < 0 {
            return .red
        } else if days <= 3 {
            return .orange
        } else {
            return .gray
        }
    }
    
    private var expirationText: String? {
        item.expirationText
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name)
                    .font(.system(.subheadline, design: .rounded))
                Spacer()
                Text(String(format: "%.1f %@", item.amount, item.unit.rawValue))
                    .font(.system(.subheadline, design: .rounded))
            }
            
            HStack {
                if let text = expirationText {
                    Text("• \(text)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(expirationColor)
                }
                
                Spacer()
                
                Text(String(format: "%.2f €", item.totalValue))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.brown)
            }
        }
        .padding(.vertical, 4)
    }
}
