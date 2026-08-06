import SwiftUI

/// Çoktan seçmeli kelime ezberleme. Soru iki modda sorulabilir:
/// Türkçe anlam veya İngilizce eş anlamlı. Mod, sorunun çerçeve rengi ve
/// başlığıyla ayırt edilir. Doğru cevapta sayaç artar, yanlışta azalır;
/// sayaç eşiğe ulaşınca kelime ezberlenmiş sayılıp havuzdan çıkar.
struct VocabPracticeView: View {
    let words: [VocabWord]
    let title: String

    @StateObject private var settings = AppSettings.shared

    enum QuizMode {
        case meaning
        case synonym

        var label: String {
            switch self {
            case .meaning: return "Türkçe anlamı"
            case .synonym: return "Eş anlamlısı"
            }
        }

        var frameColor: Color {
            switch self {
            case .meaning: return .indigo
            case .synonym: return .orange
            }
        }

        var icon: String {
            switch self {
            case .meaning: return "character.book.closed.fill"
            case .synonym: return "arrow.left.arrow.right.circle.fill"
            }
        }
    }

    @State private var currentWord: VocabWord?
    @State private var mode: QuizMode = .meaning
    @State private var options: [String] = []
    @State private var correctOption: String = ""
    @State private var selectedOption: String?
    @State private var isAnswerRevealed = false
    @State private var isPoolExhausted = false
    @State private var isShowingRemoveConfirm = false
    @State private var isShowingWordHelp = false
    @State private var poolVersion = 0

    var body: some View {
        Group {
            if words.isEmpty {
                ContentUnavailableView("Bu kategoride henüz kelime yok", systemImage: "text.book.closed")
            } else if isPoolExhausted {
                finishedView
            } else if let currentWord {
                quizBody(for: currentWord)
            } else {
                Color.clear
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if currentWord == nil && !isPoolExhausted {
                pickNextWord()
            }
        }
    }

    // MARK: - Pool

    private var activeWords: [VocabWord] {
        _ = poolVersion
        return words.filter { !VocabProgressStore.shared.isRemoved($0.id) }
    }

    private var remainingPool: [VocabWord] {
        activeWords.filter { !VocabProgressStore.shared.isMastered($0.id) }
    }

    private var masteredCount: Int {
        activeWords.count - remainingPool.count
    }

    private func pickNextWord() {
        guard let next = remainingPool.randomElement() else {
            currentWord = nil
            isPoolExhausted = true
            return
        }
        currentWord = next
        mode = chooseMode(for: next)
        buildOptions(for: next, mode: mode)
        selectedOption = nil
        isAnswerRevealed = false
        isShowingRemoveConfirm = false
    }

    /// Eş anlamlı sorusu yalnızca eş anlamlılığın anlamlı olduğu türlerde sorulur;
    /// bağlaç/edat gibi işlev sözcüklerinde sorulmaz.
    private static let synonymEligibleTypes: Set<WordType> = [.adjective, .verb, .noun, .phrasalVerb]

    /// Eş anlamlı modu yalnızca ayar açıkken, uygun türde ve kelimenin
    /// eş anlamlısı varken (ve yeterli çeldirici bulunabiliyorken) kullanılır.
    private func chooseMode(for word: VocabWord) -> QuizMode {
        guard settings.isSynonymModeEnabled,
              Self.synonymEligibleTypes.contains(word.wordType),
              let synonyms = word.synonyms, !synonyms.isEmpty,
              synonymDistractorPool(excluding: word).count >= 3
        else { return .meaning }
        return Bool.random() ? .synonym : .meaning
    }

    private func synonymDistractorPool(excluding word: VocabWord) -> [VocabWord] {
        activeWords.filter {
            $0.id != word.id
                && Self.synonymEligibleTypes.contains($0.wordType)
                && !($0.synonyms ?? []).isEmpty
        }
    }

    private func buildOptions(for word: VocabWord, mode: QuizMode) {
        switch mode {
        case .meaning:
            correctOption = word.meaning
            var pool = activeWords.filter { $0.id != word.id && $0.wordType == word.wordType }
            if pool.count < 3 {
                pool = activeWords.filter { $0.id != word.id }
            }
            let distractors = pool.shuffled().prefix(3).map(\.meaning)
            options = ([correctOption] + distractors).shuffled()

        case .synonym:
            correctOption = word.synonyms?.randomElement() ?? word.meaning
            let pool = activeWords.filter { $0.id != word.id && !($0.synonyms ?? []).isEmpty }
            var distractors: [String] = []
            for candidate in pool.shuffled() {
                if let synonym = candidate.synonyms?.randomElement(),
                   synonym.lowercased() != correctOption.lowercased(),
                   !distractors.contains(where: { $0.lowercased() == synonym.lowercased() }) {
                    distractors.append(synonym)
                }
                if distractors.count == 3 { break }
            }
            options = ([correctOption] + distractors).shuffled()
        }
    }

    // MARK: - Quiz body

    private func quizBody(for word: VocabWord) -> some View {
        let frameColor = mode.frameColor
        return ScrollView {
            VStack(spacing: 24) {
                Text("\(masteredCount)/\(activeWords.count) ezberlendi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)

                VStack(spacing: 14) {
                    Label(mode.label, systemImage: mode.icon)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(frameColor.opacity(0.18), in: Capsule())
                        .foregroundStyle(frameColor)

                    Text(word.term)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Doğru cevap sayacı: \(VocabProgressStore.shared.correctCount(for: word.id))/\(VocabProgressStore.masteryThreshold)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 26)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(frameColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(frameColor, lineWidth: 3)
                )
                .overlay(alignment: .topTrailing) {
                    Button {
                        isShowingWordHelp = true
                    } label: {
                        Label("AI", systemImage: "sparkles")
                            .font(.caption.weight(.bold))
                            .labelStyle(.titleAndIcon)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(frameColor.gradient, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        optionButton(option: option, word: word)
                    }
                }
                .padding(.horizontal)

                if isAnswerRevealed {
                    Button {
                        pickNextWord()
                    } label: {
                        Text("Sonraki Kelime")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(frameColor.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                // Onay, diyalog yerine butonun hemen üstünde satır içi çıkar.
                if isShowingRemoveConfirm {
                    VStack(spacing: 10) {
                        Text("Bu kelimeyi listeden kalıcı olarak çıkar?")
                            .font(.subheadline.weight(.medium))
                            .multilineTextAlignment(.center)
                        Text("Daha sonra \"Listeden Çıkarılanlar\" ekranından geri ekleyebilirsin.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 10) {
                            Button {
                                withAnimation { isShowingRemoveConfirm = false }
                            } label: {
                                Text("Hayır")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(.primary)
                            }
                            .buttonStyle(.plain)

                            Button {
                                VocabProgressStore.shared.removeWord(word.id)
                                isShowingRemoveConfirm = false
                                poolVersion += 1
                                pickNextWord()
                            } label: {
                                Text("Evet, çıkar")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.gradient, in: RoundedRectangle(cornerRadius: 10))
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Button(role: .destructive) {
                    withAnimation { isShowingRemoveConfirm.toggle() }
                } label: {
                    Label("Bu kelimeyi listeden çıkar", systemImage: "trash")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .id(word.id)
        .sheet(isPresented: $isShowingWordHelp) {
            WordHelpView(word: word)
        }
    }

    private func optionButton(option: String, word: VocabWord) -> some View {
        let isSelected = selectedOption == option
        let isCorrectOption = option == correctOption

        let backgroundColor: Color = {
            guard isAnswerRevealed else {
                return Color(.secondarySystemBackground)
            }
            if isCorrectOption { return Color.green.opacity(0.25) }
            if isSelected { return Color.red.opacity(0.25) }
            return Color(.secondarySystemBackground)
        }()

        return Button {
            guard !isAnswerRevealed else { return }
            selectedOption = option
            isAnswerRevealed = true
            if isCorrectOption {
                VocabProgressStore.shared.registerCorrectAnswer(for: word.id)
            } else {
                VocabProgressStore.shared.registerWrongAnswer(for: word.id)
            }
        } label: {
            HStack {
                Text(option)
                Spacer()
                if isAnswerRevealed && isCorrectOption {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else if isAnswerRevealed && isSelected {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                }
            }
            .padding()
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(isAnswerRevealed)
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Tebrikler!")
                .font(.title2.bold())
            Text("Bu kategorideki tüm kelimeleri ezberledin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 64)
    }
}
