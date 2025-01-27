import SwiftUI
import SwiftData

struct InventoryItemRow: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.system(.headline, design: .rounded))
            
            HStack {
                Text("\(String(format: "%.1f", item.amount)) \(item.unit.rawValue)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
                
                if let days = item.daysUntilExpiration {
                    Text("• \(item.expirationText ?? "")")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(item.isNearExpiration ? .orange : .gray)
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