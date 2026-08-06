import Foundation
import SwiftUI

/// Kullanıcının açıp kapatabildiği uygulama ayarları.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let synonymModeKey = "yds70.synonymModeEnabled"

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
    }
}
