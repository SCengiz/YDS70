import SwiftUI

/// Ezberlenen (20 kez doğru cevaplanmış) kelimeleri kategoriye göre,
/// İngilizce ve Türkçe karşılıklarını yan yana göstererek listeler.
struct MasteredWordsView: View {
    private var masteredByType: [(type: WordType, words: [VocabWord])] {
        WordType.allCases.compactMap { type in
            let mastered = VocabBank.shared.words(of: type).filter { VocabProgressStore.shared.isMastered($0.id) }
            return mastered.isEmpty ? nil : (type, mastered.sorted { $0.term.lowercased() < $1.term.lowercased() })
        }
    }

    var body: some View {
        Group {
            if masteredByType.isEmpty {
                ContentUnavailableView(
                    "Henüz ezberlenen kelime yok",
                    systemImage: "checkmark.seal",
                    description: Text("Bir kelimeyi 20 kez doğru cevaplayınca burada listelenir.")
                )
            } else {
                List {
                    ForEach(masteredByType, id: \.type) { entry in
                        Section(entry.type.displayName) {
                            ForEach(entry.words) { word in
                                HStack {
                                    Text(word.term)
                                        .font(.body.weight(.medium))
                                    Spacer()
                                    Text(word.meaning)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Ezberlenen Kelimeler")
        .navigationBarTitleDisplayMode(.inline)
    }
}
