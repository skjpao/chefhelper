import SwiftUI

struct ExpirationWarningView: View {
    let items: [InventoryItem]
    
    private var sortedItems: ([InventoryItem], [InventoryItem]) {
        let validItems = items.filter { $0.expirationDate != nil }
        let expired = validItems.filter { $0.daysUntilExpiration ?? 0 < 0 }
            .sorted { ($0.daysUntilExpiration ?? Int.min) > ($1.daysUntilExpiration ?? Int.min) }
        let notExpired = validItems.filter { $0.daysUntilExpiration ?? 0 >= 0 }
            .sorted { ($0.daysUntilExpiration ?? Int.max) < ($1.daysUntilExpiration ?? Int.max) }
        return (notExpired, expired)
    }
    
    private func textColor(for item: InventoryItem) -> Color {
        guard let days = item.daysUntilExpiration else { return .black }
        if days <= 3 {
            return .black
        } else {
            return .black
        }
    }
    
    var body: some View {
        let (notExpired, expired) = sortedItems
        
        List {
            if !notExpired.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("expiring_products".localized)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        
                        ForEach(notExpired) { item in
                            HStack {
                                Text(item.name)
                                    .foregroundColor(.black)
                                Spacer()
                                if let text = item.expirationText {
                                    Text(text)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            if !expired.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("expired".localized)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        ForEach(expired) { item in
                            HStack {
                                Text(item.name)
                                    .foregroundColor(.black)
                                Spacer()
                                if let text = item.expirationText {
                                    Text(text)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
} 
