import SwiftUI

enum WordTypeStyle {
    static func icon(for type: WordType?) -> String {
        guard let type else { return "square.stack.3d.up.fill" }
        switch type {
        case .verb: return "bolt.fill"
        case .phrasalVerb: return "link"
        case .adjective: return "sparkles"
        }
    }

    static func color(for type: WordType?) -> Color {
        guard let type else { return .indigo }
        switch type {
        case .verb: return .blue
        case .phrasalVerb: return .teal
        case .adjective: return .purple
        }
    }
}
