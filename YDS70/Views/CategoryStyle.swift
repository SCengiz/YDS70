import SwiftUI

/// Her soru kategorisi için ayırt edici ikon ve renk eşlemesi.
enum CategoryStyle {
    static func icon(for category: QuestionCategory) -> String {
        switch category {
        case .vocabulary: return "character.book.closed.fill"
        case .grammar: return "textformat"
        case .clozeTest: return "square.dashed"
        case .sentenceCompletion: return "text.append"
        case .translation: return "arrow.left.arrow.right"
        case .paragraph: return "doc.text.fill"
        case .dialogueCompletion: return "bubble.left.and.bubble.right.fill"
        case .restatement: return "arrow.triangle.2.circlepath"
        case .paragraphCompletion: return "text.badge.plus"
        case .irrelevantSentence: return "exclamationmark.triangle.fill"
        case .custom: return "tray.and.arrow.down.fill"
        }
    }

    static func color(for category: QuestionCategory) -> Color {
        switch category {
        case .vocabulary: return .orange
        case .grammar: return .blue
        case .clozeTest: return .purple
        case .sentenceCompletion: return .teal
        case .translation: return .pink
        case .paragraph: return .indigo
        case .dialogueCompletion: return .green
        case .restatement: return .red
        case .paragraphCompletion: return .yellow
        case .irrelevantSentence: return .mint
        case .custom: return .brown
        }
    }
}
