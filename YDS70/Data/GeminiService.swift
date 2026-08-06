import Foundation

/// Kelime yardımı için Google Gemini API'sine istek atar.
/// Ücretsiz katmanda çalışan `gemini-2.5-flash` modeli kullanılır; anahtarı
/// kullanıcı kendi Google AI Studio hesabından alıp ayarlardan girer.
enum GeminiService {
    struct WordInsight: Decodable {
        let turkce: String
        let esAnlamlilar: [String]
        let ornekCumle: String
        let ornekCumleTurkce: String
        let kullanimNotu: String
    }

    enum ServiceError: LocalizedError {
        case missingKey
        case invalidKey
        case quotaExceeded
        case server(String)
        case emptyResponse

        var errorDescription: String? {
            switch self {
            case .missingKey:
                return "API anahtarı girilmemiş. Ayarlar bölümünden Gemini anahtarını ekleyebilirsin."
            case .invalidKey:
                return "API anahtarı geçersiz görünüyor. Ayarlardan anahtarı kontrol et."
            case .quotaExceeded:
                return "Ücretsiz kullanım sınırına ulaşıldı. Biraz sonra tekrar dene."
            case .emptyResponse:
                return "Gemini boş yanıt döndürdü. Tekrar dener misin?"
            case .server(let message):
                return message
            }
        }
    }

    /// Verilen kelime için Türkçe anlam, eş anlamlılar ve örnek cümle üretir.
    static func explain(word: String, wordType: String) async throws -> WordInsight {
        guard let apiKey = AppSettings.shared.geminiAPIKey else {
            throw ServiceError.missingKey
        }

        let prompt = """
        Sen YDS/YÖKDİL sınavına hazırlanan bir Türk öğrenciye yardım eden İngilizce öğretmenisin.
        Aşağıdaki İngilizce kelimeyi açıkla.

        Kelime: \(word)
        Tür: \(wordType)

        Kurallar:
        - "turkce": kelimenin Türkçe karşılığı/karşılıkları, virgülle ayrılmış, kısa.
        - "esAnlamlilar": İngilizce eş anlamlı kelimeler, en fazla 5 tane. Yoksa boş liste.
        - "ornekCumle": kelimeyi kullanan, YDS seviyesinde tek bir İngilizce cümle.
        - "ornekCumleTurkce": bu cümlenin Türkçe çevirisi.
        - "kullanimNotu": kelimenin nerede/nasıl kullanıldığına dair tek cümlelik Türkçe not.
        """

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                // Basit bir sözlük sorgusu; düşünme bütçesi kapatılarak yanıt hızlandırılır.
                "thinkingConfig": ["thinkingBudget": 0],
                "responseMimeType": "application/json",
                "responseSchema": [
                    "type": "OBJECT",
                    "properties": [
                        "turkce": ["type": "STRING"],
                        "esAnlamlilar": ["type": "ARRAY", "items": ["type": "STRING"]],
                        "ornekCumle": ["type": "STRING"],
                        "ornekCumleTurkce": ["type": "STRING"],
                        "kullanimNotu": ["type": "STRING"]
                    ],
                    "required": ["turkce", "esAnlamlilar", "ornekCumle", "ornekCumleTurkce", "kullanimNotu"]
                ]
            ]
        ]

        let model = AppSettings.shared.geminiModel
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            switch http.statusCode {
            case 400, 401, 403: throw ServiceError.invalidKey
            case 429: throw ServiceError.quotaExceeded
            default:
                let message = apiErrorMessage(from: data) ?? "Gemini isteği başarısız oldu (kod \(http.statusCode))."
                throw ServiceError.server(message)
            }
        }

        guard let text = firstTextPart(in: data) else { throw ServiceError.emptyResponse }
        guard let insightData = text.data(using: .utf8) else { throw ServiceError.emptyResponse }
        return try JSONDecoder().decode(WordInsight.self, from: insightData)
    }

    /// Yanıt gövdesindeki ilk metin parçasını çıkarır.
    private static func firstTextPart(in data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = root["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]]
        else { return nil }
        let joined = parts.compactMap { $0["text"] as? String }.joined()
        return joined.isEmpty ? nil : joined
    }

    private static func apiErrorMessage(from data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = root["error"] as? [String: Any],
              let message = error["message"] as? String
        else { return nil }
        return message
    }
}
