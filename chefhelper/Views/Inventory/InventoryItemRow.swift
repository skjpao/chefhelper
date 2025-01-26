import SwiftUI
import SwiftData

struct InventoryItemRow: View {
    @Bindable var item: InventoryItem
    @Binding var itemToEdit: InventoryItem?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.brown)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(String(format: "%.2f €/%@", item.pricePerUnit, item.unit.rawValue))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if let expirationDate = item.expirationDate {
                Text(dateFormatter.string(from: expirationDate))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(item.isNearExpiration ? .red : .gray)
                    .frame(width: 80)
            } else {
                Text("-")
                    .foregroundColor(.gray)
                    .frame(width: 80)
            }
            
            HStack(spacing: 2) {
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
        .padding(.horizontal)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            itemToEdit = item
        }
    }
}