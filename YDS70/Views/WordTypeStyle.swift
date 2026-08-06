import SwiftUI

enum WordTypeStyle {
    static func icon(for type: WordType?) -> String {
        guard let type else { return "square.stack.3d.up.fill" }
        switch type {
        case .verb: return "bolt.fill"
        case .phrasalVerb: return "link"
        case .adjective: return "sparkles"
        case .conjunction: return "arrow.triangle.branch"
        case .preposition: return "arrow.turn.down.right"
        case .noun: return "cube.fill"
        case .adverb: return "speedometer"
        case .general: return "star.fill"
        }
    }

    static func color(for type: WordType?) -> Color {
        guard let type else { return .indigo }
        switch type {
        case .verb: return .blue
        case .phrasalVerb: return .teal
        case .adjective: return .purple
        case .conjunction: return .orange
        case .preposition: return .pink
        case .noun: return .brown
        case .adverb: return .green
        case .general: return .yellow
        }
    }
}
