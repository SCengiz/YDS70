import Foundation
import SwiftUI

/// Kullanıcının açıp kapatabildiği uygulama ayarları.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let synonymModeKey = "yds70.synonymModeEnabled"
    private let apiKeyKeychainKey = "yds70.geminiAPIKey"
    private let modelKey = "yds70.geminiModel"

    /// Kullanıcının kendi Gemini API anahtarı. Keychain'de saklanır; burada
    /// yalnızca "anahtar var mı" bilgisi yayınlanır ki arayüz güncellensin.
    @Published private(set) var hasGeminiAPIKey = false

    /// AI açıklamasında kullanılacak Gemini modeli.
    @Published var geminiModel: String {
        didSet { UserDefaults.standard.set(geminiModel, forKey: modelKey) }
    }

    var geminiAPIKey: String? {
        KeychainStore.string(for: apiKeyKeychainKey)
    }

    func setGeminiAPIKey(_ key: String?) {
        let trimmed = key?.trimmingCharacters(in: .whitespacesAndNewlines)
        KeychainStore.set(trimmed, for: apiKeyKeychainKey)
        hasGeminiAPIKey = !(trimmed ?? "").isEmpty
    }

    /// Açıkken kelime sorularının bir kısmı Türkçe anlam yerine
    /// İngilizce eş anlamlı sorar.
    @Published var isSynonymModeEnabled: Bool {
        didSet { UserDefaults.standard.set(isSynonymModeEnabled, forKey: synonymModeKey) }
    }

    private init() {
        if UserDefaults.standard.object(forKey: synonymModeKey) == nil {
            isSynonymModeEnabled = true
        } else {
            isSynonymModeEnabled = UserDefaults.standard.bool(forKey: synonymModeKey)
        }
        let storedModel = UserDefaults.standard.string(forKey: modelKey)
        geminiModel = GeminiModel(rawValue: storedModel ?? "")?.rawValue ?? GeminiModel.flash.rawValue
        hasGeminiAPIKey = KeychainStore.string(for: apiKeyKeychainKey) != nil
    }
}
