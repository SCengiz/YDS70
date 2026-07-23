import SwiftUI

struct VocabTopicView: View {
    @Binding var path: NavigationPath

    @State private var isShowingImportSheet = false

    private let options: [WordType?] = [nil] + WordType.allCases

    var body: some View {
        List {
            ForEach(options, id: \.self) { type in
                let words = VocabBank.shared.words(of: type)
                let mastered = VocabProgressStore.shared.masteredCount(among: words)
                let color = WordTypeStyle.color(for: type)
                Button {
                    path.append(VocabRoute.vocabPractice(words: words, title: type?.displayName ?? "Tüm Kelimeler"))
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: WordTypeStyle.icon(for: type))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(color)
                            .frame(width: 36, height: 36)
                            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(type?.displayName ?? "Tüm Kelimeler")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                            Text("\(mastered)/\(words.count) ezberlendi")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !words.isEmpty {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
                .disabled(words.isEmpty)
            }
        }
        .navigationTitle("Kelime Ezberle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingImportSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingImportSheet) {
            VocabImportView()
        }
    }
}
