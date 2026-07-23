import SwiftUI
import Translation

/// Verilen metni kelime kelime gösterir; bir kelimeye basılı tutunca
/// anlık olarak Türkçe çevirisini balon içinde gösterir, parmak kalkınca kaybolur.
struct TranslatableText: View {
    let text: String
    var font: Font = .body

    @State private var configuration: TranslationSession.Configuration?
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
            guard let pressedWordKey, pressedWordKey < words.count else { return }
            let cleaned = cleanWord(words[pressedWordKey])
            guard !cleaned.isEmpty else { return }
            do {
                let response = try await session.translate(cleaned)
                if self.pressedWordKey == pressedWordKey {
                    translation = response.targetText
                }
            } catch {
                translation = nil
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if pressedWordKey != key {
                            pressedWordKey = key
                            translation = nil
                            requestTranslation()
                        }
                    }
                    .onEnded { _ in
                        pressedWordKey = nil
                        translation = nil
                    }
            )
    }

    private func cleanWord(_ word: String) -> String {
        word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
    }

    private func requestTranslation() {
        if configuration == nil {
            configuration = TranslationSession.Configuration(
                source: Locale.Language(identifier: "en"),
                target: Locale.Language(identifier: "tr")
            )
        } else {
            configuration?.invalidate()
        }
    }
}
