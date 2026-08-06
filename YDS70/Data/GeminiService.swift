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

        let model = AppSettings.shared.geminiModel

        var generationConfig: [String: Any] = [
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

        // Düşünme bütçesi yalnızca 2.5 ailesinde var; eski modellere gönderilirse
        // istek 400 ile reddedilir.
        if model.hasPrefix("gemini-2.5") {
            generationConfig["thinkingConfig"] = ["thinkingBudget": 0]
        }

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": generationConfig
        ]

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        try throwIfFailed(response: response, data: data)

        guard let text = firstTextPart(in: data) else { throw ServiceError.emptyResponse }
        guard let insightData = text.data(using: .utf8) else { throw ServiceError.emptyResponse }
        return try JSONDecoder().decode(WordInsight.self, from: insightData)
    }

    /// Anahtarın gerçekten erişebildiği, metin üretebilen modelleri listeler.
    /// Model adları zamanla değiştiği için sabit liste yerine bu uçtan okunur.
    static func availableModels() async throws -> [String] {
        guard let apiKey = AppSettings.shared.geminiAPIKey else {
            throw ServiceError.missingKey
        }

        var url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models")!
        url.append(queryItems: [URLQueryItem(name: "pageSize", value: "200")])
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        let (data, response) = try await URLSession.shared.data(for: request)
        try throwIfFailed(response: response, data: data)

        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let models = root["models"] as? [[String: Any]]
        else { throw ServiceError.emptyResponse }

        let names: [String] = models.compactMap { model in
            let methods = model["supportedGenerationMethods"] as? [String] ?? []
            guard methods.contains("generateContent"),
                  let name = model["name"] as? String
            else { return nil }
            let short = name.replacingOccurrences(of: "models/", with: "")
            // Görsel/ses üreten ve gömme (embedding) modelleri kelime açıklaması için uygun değil.
            guard !short.contains("embedding"),
                  !short.contains("image"),
                  !short.contains("tts"),
                  !short.contains("vision")
            else { return nil }
            return short
        }

        return Array(Set(names)).sorted()
    }

    private static func throwIfFailed(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse,
              !(200..<300).contains(http.statusCode)
        else { return }

        // Sunucunun kendi açıklaması (ör. "model bulunamadı") en yararlı bilgi;
        // varsa olduğu gibi gösterilir.
        let message = apiErrorMessage(from: data)
        switch http.statusCode {
        case 401, 403:
            throw ServiceError.invalidKey
        case 429:
            throw ServiceError.quotaExceeded
        default:
            throw ServiceError.server(message ?? "Gemini isteği başarısız oldu (kod \(http.statusCode)).")
        }
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
