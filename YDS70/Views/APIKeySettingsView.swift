import SwiftUI

/// Yapay zekâ ayarları: model seçimi ve kullanıcının kendi Gemini API anahtarı.
/// Anahtar Keychain'de saklanır ve yalnızca AI açıklaması istenirken kullanılır.
struct APIKeySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = AppSettings.shared

    @State private var apiKey = ""

    private static let keyURL = URL(string: "https://aistudio.google.com/apikey")!

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Sağlayıcı", value: "Google Gemini")

                    Picker("Model", selection: $settings.geminiModel) {
                        ForEach(GeminiModel.allCases) { model in
                            Text(model.title).tag(model.rawValue)
                        }
                    }

                    Text(GeminiModel(rawValue: settings.geminiModel)?.summary ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    SecureField("API anahtarı", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    HStack {
                        Button("Kaydet") {
                            settings.setGeminiAPIKey(apiKey)
                            apiKey = ""
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
                    Text("Yapay zekâ")
                } footer: {
                    Text("Anahtar yalnızca bu cihazın Keychain'inde saklanır. Kelime ekranındaki AI tuşuna bastığında çeviri, eş anlamlılar ve örnek cümle için kullanılır.")
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
        }
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
