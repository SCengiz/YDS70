import Foundation

/// Kelime yardımı için kullanılabilecek Gemini modelleri.
/// İkisi de ücretsiz katmanda çalışır; lite daha hızlı ve kotayı daha az yer.
enum GeminiModel: String, CaseIterable, Identifiable {
    case flash = "gemini-2.5-flash"
    case flashLite = "gemini-2.5-flash-lite"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .flash: return "Flash"
        case .flashLite: return "Flash Lite"
        }
    }

    var summary: String {
        switch self {
        case .flash: return "Dengeli seçim: açıklamalar daha ayrıntılı ve isabetli."
        case .flashLite: return "Daha hızlı ve ücretsiz kotayı daha az tüketir."
        }
    }
}
