import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: Category
    
    var body: some View {
        Picker("category".localized, selection: $selectedCategory) {
            ForEach(Category.allCases, id: \.self) { category in
                HStack {
                    Text(category.rawValue)
                    if category != .all {
                        Image(systemName: categoryIcon(for: category))
                    }
                }.tag(category)
            }
        }
        .pickerStyle(.menu)
    }
    
    private func categoryIcon(for category: Category) -> String {
        switch category {
        case .all:
            return ""
        case .fresh:
            return "leaf"
        case .dry:
            return "shippingbox"
        case .misc:
            return "ellipsis.circle"
        }
    }
} 