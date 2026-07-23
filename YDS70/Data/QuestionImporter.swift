import Foundation

/// Kullanıcının kendi yazdığı/derlediği soruları (metin, PDF veya görsel
/// olarak) çoktan seçmeli soru listesine dönüştürür.
///
/// Beklenen biçim: her soru bir numara ile başlar ("1." gibi), seçenekler
/// "A)", "B)", "C)"... ile başlar, doğru cevap ya soru altında
/// "Doğru Cevap: B" satırıyla ya da metnin sonunda "CEVAP ANAHTARI"
/// başlığı altında "1) B" biçiminde bir liste olarak belirtilir.
enum QuestionImporter {
    private static let questionNumberRegex = try! NSRegularExpression(pattern: #"^(\d+)[.)]\s*(.*)$"#)
    private static let optionRegex = try! NSRegularExpression(pattern: #"^([A-Fa-f])[).]\s*(.*)$"#)
    private static let inlineAnswerRegex = try! NSRegularExpression(
        pattern: #"^(Doğru\s*Cevap|Cevap)\s*:?\s*([A-Fa-f])\s*$"#,
        options: [.caseInsensitive]
    )
    private static let answerKeyHeadings = ["CEVAP ANAHTARI", "CEVAPLAR"]
    private static let answerKeyLineRegex = try! NSRegularExpression(pattern: #"^(\d+)\s*[).:\-]\s*([A-Fa-f])\s*$"#)

    private struct DraftQuestion {
        let number: Int
        var stemLines: [String] = []
        var options: [String: String] = [:]
        var inlineAnswer: String?
    }

    static func parse(text: String) -> (questions: [Question], skippedBlocks: [String]) {
        var questionPart = text
        var answerKey: [Int: String] = [:]

        for heading in answerKeyHeadings {
            if let range = text.range(of: heading, options: .caseInsensitive) {
                questionPart = String(text[text.startIndex..<range.lowerBound])
                let keyPart = String(text[range.upperBound...])
                answerKey = parseAnswerKey(keyPart)
                break
            }
        }

        var drafts: [DraftQuestion] = []
        var current: DraftQuestion?

        func finalizeCurrent() {
            if let draft = current { drafts.append(draft) }
            current = nil
        }

        for rawLine in questionPart.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }

            if let match = firstMatch(inlineAnswerRegex, in: line), current != nil {
                let letter = (line as NSString).substring(with: match.range(at: 2)).uppercased()
                current?.inlineAnswer = letter
                continue
            }
            if let match = firstMatch(questionNumberRegex, in: line) {
                finalizeCurrent()
                let number = Int((line as NSString).substring(with: match.range(at: 1))) ?? (drafts.count + 1)
                var draft = DraftQuestion(number: number)
                let rest = (line as NSString).substring(with: match.range(at: 2))
                if !rest.isEmpty { draft.stemLines.append(rest) }
                current = draft
                continue
            }
            if let match = firstMatch(optionRegex, in: line) {
                let letter = (line as NSString).substring(with: match.range(at: 1)).uppercased()
                let optionText = (line as NSString).substring(with: match.range(at: 2))
                current?.options[letter] = optionText
                continue
            }
            // continuation line
            if current != nil {
                if let lastKey = current?.options.keys.sorted().last, current?.options[lastKey] != nil {
                    current?.options[lastKey]! += " " + line
                } else {
                    current?.stemLines.append(line)
                }
            }
        }
        finalizeCurrent()

        var questions: [Question] = []
        var skipped: [String] = []

        for draft in drafts {
            let stem = draft.stemLines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
            let sortedLetters = draft.options.keys.sorted()
            let options = sortedLetters.compactMap { draft.options[$0] }
            let letter = draft.inlineAnswer ?? answerKey[draft.number]

            guard !stem.isEmpty, options.count >= 2, let letter,
                  let letterIndex = sortedLetters.firstIndex(of: letter) else {
                let summary = "\(draft.number). \(stem.prefix(60))"
                skipped.append(summary)
                continue
            }

            questions.append(
                Question(
                    id: "user-q-\(UUID().uuidString)",
                    examType: .both,
                    category: .custom,
                    passage: nil,
                    promptText: stem,
                    options: options,
                    correctIndex: letterIndex,
                    explanation: nil,
                    sourceNote: "Kullanıcı tarafından eklendi"
                )
            )
        }

        return (questions, skipped)
    }

    private static func parseAnswerKey(_ text: String) -> [Int: String] {
        var result: [Int: String] = [:]
        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            if let match = firstMatch(answerKeyLineRegex, in: line) {
                let number = Int((line as NSString).substring(with: match.range(at: 1)))
                let letter = (line as NSString).substring(with: match.range(at: 2)).uppercased()
                if let number { result[number] = letter }
            }
        }
        return result
    }

    private static func firstMatch(_ regex: NSRegularExpression, in line: String) -> NSTextCheckingResult? {
        regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line))
    }
}
