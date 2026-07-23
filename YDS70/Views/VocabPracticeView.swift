import SwiftUI

struct VocabPracticeView: View {
    let words: [VocabWord]
    let title: String

    @State private var currentIndex = 0
    @State private var isRevealed = false
    @State private var knownCount = 0
    @State private var isFinished = false

    var body: some View {
        Group {
            if words.isEmpty {
                ContentUnavailableView("Bu kategoride henüz kelime yok", systemImage: "text.book.closed")
            } else if isFinished {
                finishedView
            } else {
                cardView
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentWord: VocabWord { words[currentIndex] }

    private var cardView: some View {
        VStack(spacing: 24) {
            Text("\(currentIndex + 1)/\(words.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 24)

            Spacer()

            VStack(spacing: 16) {
                Text(currentWord.term)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                if isRevealed {
                    Text(currentWord.meaning)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(minHeight: 160)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .onTapGesture { isRevealed = true }

            Spacer()

            if !isRevealed {
                Button {
                    isRevealed = true
                } label: {
                    Text("Anlamı Göster")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            } else {
                HStack(spacing: 12) {
                    Button {
                        VocabProgressStore.shared.markUnknown(currentWord.id)
                        advance()
                    } label: {
                        Text("Bilmiyorum")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.15))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        VocabProgressStore.shared.markKnown(currentWord.id)
                        knownCount += 1
                        advance()
                    } label: {
                        Text("Biliyorum")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.15))
                            .foregroundStyle(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Text("\(knownCount)/\(words.count)")
                .font(.system(size: 48, weight: .bold))
            Text("Bildiğin Kelime")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 64)
    }

    private func advance() {
        isRevealed = false
        if currentIndex == words.count - 1 {
            isFinished = true
        } else {
            currentIndex += 1
        }
    }
}
