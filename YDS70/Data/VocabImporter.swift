import Foundation
import NaturalLanguage
import PDFKit

/// Kullanıcının yapıştırdığı metni veya yüklediği PDF'i kelime listesine
/// dönüştürür: satırları terim/anlam olarak ayırır ve kelime türünü
/// (fiil / phrasal verb / sıfat) otomatik sınıflandırır.
enum VocabImporter {
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

    static func parse(text: String) -> (words: [VocabWord], skippedLines: [String]) {
        var words: [VocabWord] = []
        var skipped: [String] = []

        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }

            guard let (term, meaning) = parseLine(line) else {
                skipped.append(line)
                continue
            }
            guard let type = classify(term) else {
                skipped.append(line)
                continue
            }
            let id = "user-\(type.rawValue)-\(term.lowercased())"
            words.append(VocabWord(id: id, term: term, meaning: meaning, wordType: type))
        }
        return (words, skipped)
    }

    private static func parseLine(_ line: String) -> (String, String)? {
        let separators = ["\t", " – ", " — ", " - ", ": "]
        for separator in separators {
            if let range = line.range(of: separator) {
                let term = String(line[line.startIndex..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                let meaning = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !term.isEmpty && !meaning.isEmpty {
                    return (term, meaning)
                }
            }
        }
        return nil
    }

    private static func classify(_ term: String) -> WordType? {
        let cleaned = term.trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { return nil }

        if cleaned.contains(" ") {
            return .phrasalVerb
        }

        // NLTagger cannot reliably classify a single isolated word (especially verbs,
        // which are often ambiguous with nouns out of context). Embedding it in a
        // neutral carrier sentence gives the tagger the context it needs.
        let sentence = "They often \(cleaned) it very carefully."
        guard let wordRange = sentence.range(of: cleaned) else { return nil }
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sentence
        let (tag, _) = tagger.tag(at: wordRange.lowerBound, unit: .word, scheme: .lexicalClass)
        switch tag {
        case .verb: return .verb
        case .adjective: return .adjective
        default: return nil
        }
    }
}
