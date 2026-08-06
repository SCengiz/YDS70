import Foundation

/// Kelime yardımı için önerilen Gemini modelleri. Google model adlarını zaman
/// zaman değiştirdiği için bu liste yalnızca başlangıç/yedek değerdir; ayarlardaki
/// "Modelleri yenile" anahtarın gerçekten desteklediği modelleri listeler.
enum GeminiModel: String, CaseIterable, Identifiable {
    case flash3 = "gemini-3-flash-preview"
    case flash25 = "gemini-2.5-flash"
    case flashLite25 = "gemini-2.5-flash-lite"

    /// Yeni kurulumlarda kullanılan model.
    static let `default`: GeminiModel = .flash3

    var id: String { rawValue }

    var title: String {
        switch self {
        case .flash3: return "Gemini 3 Flash (Preview)"
        case .flash25: return "Gemini 2.5 Flash"
        case .flashLite25: return "Gemini 2.5 Flash Lite"
        }
    }
}
