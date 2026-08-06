import SwiftUI

/// Yapay zekâ ayarları: model seçimi ve kullanıcının kendi Gemini API anahtarı.
/// Anahtar Keychain'de saklanır ve yalnızca AI açıklaması istenirken kullanılır.
struct APIKeySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = AppSettings.shared

    @State private var apiKey = ""
    @State private var models: [String] = []
    @State private var isLoadingModels = false
    @State private var modelError: String?

    private static let keyURL = URL(string: "https://aistudio.google.com/apikey")!

    /// Seçili model her zaman listede yer alsın ki Picker boşa düşmesin.
    private var pickerModels: [String] {
        models.contains(settings.geminiModel) ? models : ([settings.geminiModel] + models)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Sağlayıcı", value: "Google Gemini")

                    SecureField("API anahtarı", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    HStack {
                        Button("Kaydet") {
                            settings.setGeminiAPIKey(apiKey)
                            apiKey = ""
                            Task { await loadModels() }
                        }
                        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Spacer()

                        if settings.hasGeminiAPIKey {
                            Label("Kayıtlı", systemImage: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }

                    if settings.hasGeminiAPIKey {
                        Button("Anahtarı sil", role: .destructive) {
                            settings.setGeminiAPIKey(nil)
                            apiKey = ""
                        }
                    }

                    Link(destination: Self.keyURL) {
                        Label("Ücretsiz anahtar al", systemImage: "arrow.up.forward.square")
                    }
                } header: {
                    Text("API anahtarı")
                } footer: {
                    Text("Anahtar yalnızca bu cihazın Keychain'inde saklanır.")
                }

                Section {
                    Picker("Model", selection: $settings.geminiModel) {
                        ForEach(pickerModels, id: \.self) { model in
                            Text(GeminiModel(rawValue: model)?.title ?? model).tag(model)
                        }
                    }
                    .disabled(!settings.hasGeminiAPIKey)

                    Button {
                        Task { await loadModels() }
                    } label: {
                        HStack {
                            Label("Modelleri yenile", systemImage: "arrow.clockwise")
                            if isLoadingModels {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(!settings.hasGeminiAPIKey || isLoadingModels)

                    if let modelError {
                        Text(modelError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Model")
                } footer: {
                    Text(models.isEmpty
                         ? "Model adları zamanla değişir. \"Modelleri yenile\" ile anahtarının şu an desteklediği modelleri listeleyebilirsin."
                         : "Anahtarının erişebildiği \(models.count) model listelendi.")
                }

                Section("Anahtar nasıl alınır?") {
                    step(1, "Yukarıdaki \"Ücretsiz anahtar al\" bağlantısına dokun.")
                    step(2, "Google hesabınla giriş yapıp \"Create API key\" de.")
                    step(3, "Oluşan anahtarı kopyalayıp yukarıdaki alana yapıştır ve Kaydet'e bas.")
                    Text("Ücretsiz katmanda günlük istek sınırı vardır; sınır aşılırsa AI açıklaması geçici olarak çalışmaz.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("AI Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .task {
                if settings.hasGeminiAPIKey && models.isEmpty {
                    await loadModels()
                }
            }
        }
    }

    /// Anahtarın erişebildiği modelleri Google'dan çeker; seçili model artık
    /// sunulmuyorsa listedeki ilk uygun modele geçer.
    private func loadModels() async {
        isLoadingModels = true
        modelError = nil
        do {
            let fetched = try await GeminiService.availableModels()
            models = fetched
            if !fetched.isEmpty, !fetched.contains(settings.geminiModel) {
                // Seçili model artık sunulmuyorsa en yeni flash modeline geç.
                settings.geminiModel = fetched.first { $0.hasPrefix("gemini-3") && $0.contains("flash") }
                    ?? fetched.first { $0.contains("flash") }
                    ?? fetched[0]
            }
        } catch {
            modelError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoadingModels = false
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .frame(width: 22, height: 22)
                .background(Color.purple.opacity(0.18), in: Circle())
                .foregroundStyle(.purple)
            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 1)
    }
}
