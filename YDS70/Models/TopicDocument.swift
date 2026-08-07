import Foundation

/// Uygulamayla birlikte gelen PDF konu anlatımları.
/// Yeni bir doküman eklemek için PDF'i `Data/` klasörüne koyup buraya bir satır eklemek yeterli.
struct TopicDocument: Identifiable, Hashable {
    /// Uzantısız dosya adı.
    let resource: String
    let title: String
    let subtitle: String
    let symbol: String

    var id: String { resource }

    static let all: [TopicDocument] = [
        TopicDocument(
            resource: "preposition_konu_anlatimi",
            title: "Preposition (Edat)",
            subtitle: "Tüm edat konu anlatımı — PDF",
            symbol: "book.pages.fill"
        ),
        TopicDocument(
            resource: "reduction_konu_anlatimi",
            title: "Reduction (Sadeleştirme)",
            subtitle: "Cümle sadeleştirme konu anlatımı — PDF",
            symbol: "text.line.first.and.arrowtriangle.forward"
        )
    ]
}
