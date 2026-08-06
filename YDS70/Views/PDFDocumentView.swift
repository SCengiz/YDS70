import SwiftUI
import PDFKit

/// Uygulamayla birlikte gelen bir PDF konu anlatımını gösterir.
/// `resourceName` uzantısız dosya adıdır (ör. "preposition_konu_anlatimi").
struct PDFDocumentView: View {
    let resourceName: String
    let title: String

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: resourceName, withExtension: "pdf") {
                PDFKitView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ContentUnavailableView(
                    "Doküman bulunamadı",
                    systemImage: "doc.questionmark",
                    description: Text("Konu anlatımı dosyası uygulamaya eklenmemiş.")
                )
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(url: url)
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.usePageViewController(false)
        view.backgroundColor = .systemBackground
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
