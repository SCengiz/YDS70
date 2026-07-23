import Foundation
import PDFKit
import Vision
import UIKit

/// PDF ve görsellerden metin çıkarmak için ortak yardımcı (kelime ve soru
/// içe aktarma özellikleri bunu paylaşır).
enum DocumentTextExtractor {
    static func extractText(fromPDF url: URL) -> String? {
        guard let document = PDFDocument(url: url) else { return nil }
        var text = ""
        for index in 0..<document.pageCount {
            if let page = document.page(at: index), let pageText = page.string {
                text += pageText + "\n"
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text
    }

    /// Cihaz üzerinde (Vision framework) metin tanıma ile bir görselden metin çıkarır.
    static func extractText(fromImage image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                    let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
                    let joined = lines.joined(separator: "\n")
                    continuation.resume(returning: joined.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : joined)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
