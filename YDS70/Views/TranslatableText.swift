import SwiftUI
import Translation

/// Verilen metni kelime kelime gösterir; bir kelimeye basılı tutunca
/// anlık olarak Türkçe çevirisini balon içinde gösterir, parmak kalkınca kaybolur.
struct TranslatableText: View {
    let text: String
    var font: Font = .body

    @State private var configuration: TranslationSession.Configuration?
    @State private var session: TranslationSession?
    @State private var pressedWordKey: Int?
    @State private var translation: String?

    private var words: [String] {
        text.split(separator: " ").map(String.init)
    }

    var body: some View {
        FlowLayout(spacing: 4, lineSpacing: 6) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                wordView(word, key: index)
            }
        }
        .translationTask(configuration) { session in
            self.session = session
        }
        .onAppear {
            if configuration == nil {
                configuration = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "en"),
                    target: Locale.Language(identifier: "tr")
                )
            }
        }
    }

    private func wordView(_ word: String, key: Int) -> some View {
        Text(word)
            .font(font)
            .overlay(alignment: .top) {
                if pressedWordKey == key {
                    Text(translation ?? "…")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundStyle(.white)
                        .fixedSize()
                        .offset(y: -30)
                        .zIndex(1)
                }
            }
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.15, maximumDistance: 30, pressing: { isPressing in
                if isPressing {
                    guard pressedWordKey != key else { return }
                    pressedWordKey = key
                    translation = nil
                    let cleaned = cleanWord(word)
                    Task { await performTranslation(of: cleaned, for: key) }
                } else if pressedWordKey == key {
                    pressedWordKey = nil
                    translation = nil
                }
            }, perform: {})
    }

    private func performTranslation(of word: String, for key: Int) async {
        guard !word.isEmpty, let session else { return }
        do {
            let response = try await session.translate(word)
            if pressedWordKey == key {
                translation = response.targetText
            }
        } catch {
            if pressedWordKey == key {
                translation = "?"
            }
        }
    }

    private func cleanWord(_ word: String) -> String {
        word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
    }
}
