import SwiftUI

/// Kelime sorusu ekranındaki AI yardım penceresi. Uygulamadaki kayıtlı anlam ve
/// eş anlamlıları gösterir; kullanıcının Gemini anahtarı varsa çeviri, eş
/// anlamlılar ve örnek cümle için modele sorar.
struct WordHelpView: View {
    let word: VocabWord

    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = AppSettings.shared

    @State private var insight: GeminiService.WordInsight?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var storedSynonyms: [String] { word.synonyms ?? [] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    section(title: "Kayıtlı Türkçe anlamı", icon: "character.book.closed.fill") {
                        Text(word.meaning)
                            .font(.body)
                    }

                    if !storedSynonyms.isEmpty {
                        section(title: "Kayıtlı eş anlamlılar", icon: "arrow.left.arrow.right.circle.fill") {
                            capsules(storedSynonyms, color: .orange)
                        }
                    }

                    aiSection
                }
                .padding()
            }
            .navigationTitle("Kelime Yardımı")
            .navigationBarTitleDisplayMode(.inline)
            // Yarım ekran açılır; detay için yukarı sürüklenerek tam ekrana çıkar.
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .task {
                if settings.hasGeminiAPIKey && insight == nil {
                    await loadInsight()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.term)
                .font(.system(size: 30, weight: .bold))
            Text(word.wordType.displayName)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(WordTypeStyle.color(for: word.wordType).opacity(0.18), in: Capsule())
                .foregroundStyle(WordTypeStyle.color(for: word.wordType))
        }
    }

    @ViewBuilder
    private var aiSection: some View {
        section(title: "AI açıklaması", icon: "sparkles") {
            if !settings.hasGeminiAPIKey {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI açıklaması için Gemini API anahtarı gerekiyor.")
                        .font(.subheadline)
                    Text("Ezberle sekmesindeki Ayarlar bölümünden ücretsiz anahtarını ekleyebilirsin.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Gemini düşünüyor…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if let insight {
                VStack(alignment: .leading, spacing: 14) {
                    labeled("Çeviri", insight.turkce)

                    if !insight.esAnlamlilar.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Eş anlamlılar")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            capsules(insight.esAnlamlilar, color: .purple)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Örnek cümle")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(insight.ornekCumle)
                            .font(.body)
                        Text(insight.ornekCumleTurkce)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if !insight.kullanimNotu.isEmpty {
                        labeled("Kullanım notu", insight.kullanimNotu)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Model adı hatası alıyorsan Ezberle → Ayarlar → AI ekranından \"Modelleri yenile\" ile anahtarının desteklediği modeli seç.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        Task { await loadInsight() }
                    } label: {
                        Label("Tekrar dene", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
        }
    }

    private func capsules(_ items: [String], color: Color) -> some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.15), in: Capsule())
                    .foregroundStyle(color)
            }
        }
    }

    private func loadInsight() async {
        isLoading = true
        errorMessage = nil
        do {
            insight = try await GeminiService.explain(
                word: word.term,
                wordType: word.wordType.displayName
            )
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}
