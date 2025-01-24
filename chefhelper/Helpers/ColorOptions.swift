import Foundation

struct ColorOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
}

let colorOptions: [ColorOption] = [
    ColorOption(name: "Sininen", hex: "#1E88E5"),
    ColorOption(name: "Vihreä", hex: "#43A047"),
    ColorOption(name: "Punainen", hex: "#E53935"),
    ColorOption(name: "Oranssi", hex: "#FB8C00"),
    ColorOption(name: "Violetti", hex: "#8E24AA"),
    ColorOption(name: "Turkoosi", hex: "#00ACC1"),
    ColorOption(name: "Ruskea", hex: "#6D4C41"),
    ColorOption(name: "Harmaa", hex: "#757575")
] 