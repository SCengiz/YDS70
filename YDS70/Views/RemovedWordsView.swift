import SwiftUI

/// Kullanıcının listeden kalıcı olarak çıkardığı kelimeler. Buradan
/// istenirse tekrar kelime havuzuna geri eklenebilir.
struct RemovedWordsView: View {
    @State private var version = 0

    private var removedByType: [(type: WordType, words: [VocabWord])] {
        _ = version
        return WordType.allCases.compactMap { type in
            let removed = VocabBank.shared.words(of: type)
                .filter { VocabProgressStore.shared.isRemoved($0.id) }
            return removed.isEmpty ? nil : (type, removed.sorted { $0.term.lowercased() < $1.term.lowercased() })
        }
    }

    var body: some View {
        Group {
            if removedByType.isEmpty {
                ContentUnavailableView(
                    "Listeden çıkarılan kelime yok",
                    systemImage: "tray",
                    description: Text("Kelime sorusu ekranındaki \"Bu kelimeyi listeden çıkar\" ile çıkardığın kelimeler burada birikir.")
                )
            } else {
                List {
                    ForEach(removedByType, id: \.type) { entry in
                        Section(entry.type.displayName) {
                            ForEach(entry.words) { word in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(word.term)
                                            .font(.body.weight(.medium))
                                        Text(word.meaning)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Button {
                                        VocabProgressStore.shared.restoreWord(word.id)
                                        version += 1
                                    } label: {
                                        Label("Geri ekle", systemImage: "arrow.uturn.left")
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Listeden Çıkarılanlar")
        .navigationBarTitleDisplayMode(.inline)
    }
}
