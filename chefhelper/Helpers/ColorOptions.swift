import Foundation

struct ColorOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
}

let colorOptions: [ColorOption] = [
    ColorOption(name: "blue".localized, hex: "#1E88E5"),
    ColorOption(name: "green".localized, hex: "#43A047"),
    ColorOption(name: "red".localized, hex: "#E53935"),
    ColorOption(name: "orange".localized, hex: "#FB8C00"),
    ColorOption(name: "purple".localized, hex: "#8E24AA"),
    ColorOption(name: "turquoise".localized, hex: "#00ACC1"),
    ColorOption(name: "brown".localized, hex: "#6D4C41"),
    ColorOption(name: "gray".localized, hex: "#757575")
] 