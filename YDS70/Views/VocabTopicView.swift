import SwiftUI

struct VocabTopicView: View {
    @Binding var path: NavigationPath

    private let options: [WordType?] = [nil] + WordType.allCases

    var body: some View {
        List {
            ForEach(options, id: \.self) { type in
                let words = VocabBank.shared.words(of: type)
                let known = VocabProgressStore.shared.knownCount(among: words)
                Button {
                    path.append(Route.vocabPractice(words: words.shuffled(), title: type?.displayName ?? "Tüm Kelimeler"))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type?.displayName ?? "Tüm Kelimeler")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("\(known)/\(words.count) öğrenildi")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !words.isEmpty {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(words.isEmpty)
            }
        }
        .navigationTitle("Kelime Ezberle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
