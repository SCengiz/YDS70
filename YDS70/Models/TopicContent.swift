import Foundation

struct TopicContent {
    let explanation: String
    let tips: [String]

    static func content(for category: QuestionCategory) -> TopicContent {
        all[category] ?? TopicContent(explanation: "", tips: [])
    }

    private static let all: [QuestionCategory: TopicContent] = [
        .vocabulary: TopicContent(
            explanation: "YDS/YÖKDİL sınavlarında kelime bilgisi soruları genellikle bir cümlede bırakılan boşluğa uygun sıfat, fiil, isim veya phrasal verb'ü seçmenizi ister. Sorular genellikle akademik ve yarı akademik metinlerden alınır; anlam bağlamı çok önemlidir çünkü seçenekler genellikle birbirine yakın anlamlı (near-synonym) kelimelerden oluşur.",
            tips: [
                "Cümlenin tamamını okumadan seçeneklere bakmayın; bağlam kelimenin anlamını belirler.",
                "Zıtlık bildiren bağlaçlar (however, although, but, despite) varsa cümlenin iki yarısı arasında anlamca ters bir ilişki olduğunu unutmayın.",
                "Phrasal verb sorularında fiilin edatla birlikte kazandığı anlamı bilmek, fiilin tek başına anlamını bilmekten daha önemlidir.",
                "Bilmediğiniz kelimeleri elemek için kelimenin olumlu/olumsuz anlam yükünü (positive/negative connotation) belirlemeye çalışın."
            ]
        ),
        .grammar: TopicContent(
            explanation: "Gramer soruları genellikle tek bir cümle içinde bir zaman (tense), kip (modal), edat (preposition) veya bağlaç (conjunction) seçmenizi ister. Doğru seçenek hem dilbilgisi kurallarına hem de cümlenin anlamsal bağlamına uymalıdır.",
            tips: [
                "Cümledeki zaman zarflarına (by the time, since, for, already, yet) dikkat edin; bunlar doğru tense'i belirler.",
                "Bağlaç sorularında bağlacın 'sebep-sonuç', 'zıtlık', 'zaman', 'koşul' gibi hangi ilişkiyi kurduğunu belirleyin.",
                "Edat (preposition) sorularında edatın bağlı olduğu fiil veya isimle birlikte kalıplaşmış kullanımını arayın.",
                "Devrik yapı gerektiren ifadelere dikkat edin; 'Not only', 'Hardly', 'No sooner' gibi ifadeler cümle başında devrik yapı gerektirir."
            ]
        ),
        .clozeTest: TopicContent(
            explanation: "Cloze test, bir paragraf içinde birden fazla boşluk bırakılan ve her boşluğun ayrı şıkları olan bir soru tipidir. Boşluklar hem gramer hem kelime bilgisi gerektirebilir; paragrafın genel anlam bütünlüğü doğru seçimi belirler.",
            tips: [
                "Paragrafı ilk okumada boşlukları atlayarak okuyun, genel konuyu ve akışı kavrayın.",
                "Her boşluğu kendi cümlesi içinde çözmeye çalışın, ama bir önceki/sonraki cümledeki bağlaç ve zamirlere de dikkat edin.",
                "Boşluklar birbirini etkileyebilir; bir boşluğu doğru çözmek diğerini de kolaylaştırabilir.",
                "Zaman tutarlılığına dikkat edin; paragrafın geneli hangi zamanda anlatılıyorsa boşluklar da genelde o zamana uyar."
            ]
        ),
        .sentenceCompletion: TopicContent(
            explanation: "Bu soru tipinde yarım bırakılan bir cümlenin (genelde bağlaçla başlayan bir yan cümle) devamını, anlamca ve gramer açısından en uygun şekilde tamamlayan seçeneği bulmanız istenir.",
            tips: [
                "Cümlenin başındaki bağlacın (because, although, so that, in order to vb.) anlam ilişkisini belirleyin; bu, doğru devamın sebep mi, sonuç mu, amaç mı, zıtlık mı olacağını gösterir.",
                "Seçenekler arasında gramer açısından cümleye uymayanları (özne-fiil uyumsuzluğu, yanlış zaman) hemen eleyin.",
                "Anlamca doğru ama üslup/ton olarak cümleye uymayan seçeneklere dikkat edin."
            ]
        ),
        .translation: TopicContent(
            explanation: "Çeviri sorularında Türkçe bir cümlenin İngilizce karşılığını (veya tam tersini) beş seçenek arasından bulmanız istenir. Sorular genellikle karmaşık yapılar (şart cümleleri, pasif yapı, bağlaçlar) içerir.",
            tips: [
                "Önce orijinal cümledeki ana fikri ve mantıksal ilişkiyi (sebep-sonuç, zıtlık, koşul) belirleyin.",
                "Seçenekleri elerken önce anlamca yanlış olanları, sonra gramer hatası olanları eleyin.",
                "Kalıp ifadelerin birebir kelime çevirisiyle değil, anlamca eşdeğerleriyle karşılandığına dikkat edin."
            ]
        ),
        .paragraph: TopicContent(
            explanation: "Paragraf soruları, verilen bir metni okuyup ana fikir, yardımcı fikir, yazarın tutumu veya çıkarım (inference) gerektiren sorulara cevap vermenizi ister.",
            tips: [
                "Soruyu paragraftan önce okuyun; böylece paragrafı okurken neyi arayacağınızı bilirsiniz.",
                "'Ana fikir' sorularında paragrafın ilk ve son cümlesine özellikle dikkat edin.",
                "Çıkarım (inference) sorularında metinde doğrudan yazmayan ama metinden mantıksal olarak çıkarılabilecek bilgiyi arayın; metinde birebir geçen ifadelere kanmayın.",
                "Yazarın tutumunu soran sorularda kullanılan sıfat ve zarflara (surprisingly, unfortunately, remarkably) dikkat edin."
            ]
        ),
        .dialogueCompletion: TopicContent(
            explanation: "Kısa bir diyalogda eksik bırakılan repliği tamamlamanız istenir. Diyalogdaki bir önceki ve bir sonraki repliğin anlamsal tutarlılığı doğru cevabı belirler.",
            tips: [
                "Boşluktan hemen sonraki repliğe özellikle dikkat edin; çoğu zaman doğru cevabın ipucu oradadır.",
                "Diyalogdaki duygusal tonu (şaşırma, onaylama, itiraz) yakalayın; cevap bu tona uygun olmalıdır.",
                "Günlük konuşma dilindeki kalıp ifadelere (I'm afraid, that's a shame, no wonder vb.) aşina olun."
            ]
        ),
        .restatement: TopicContent(
            explanation: "Verilen bir cümleyle anlamca en yakın olan seçeneği bulmanız istenir. Doğru seçenek genelde farklı kelimeler ve yapı kullanır ama aynı anlamı taşır.",
            tips: [
                "Orijinal cümledeki bağlaçları (although, because, unless vb.) ve bunların kurduğu mantıksal ilişkiyi belirleyin; doğru seçenek bu ilişkiyi korumalıdır.",
                "Anlamı kısmen değiştiren (aşırı genelleme, ters anlam) seçenekleri eleyin.",
                "'Had it not been for', 'Were it not for' gibi kalıp yapıların anlamını iyi bilin, bunlar sık çıkar."
            ]
        ),
        .paragraphCompletion: TopicContent(
            explanation: "Bir paragrafın eksik bırakılan son (veya bazen ilk) cümlesini bulmanız istenir. Doğru seçenek paragrafın konu bütünlüğünü ve mantıksal akışını tamamlamalıdır.",
            tips: [
                "Paragrafın genel konusunu ve yönünü (bir sorunun tanıtılması, sonra çözüm önerilmesi gibi) belirleyin.",
                "Paragrafta kullanılan bağlaç kelimelerine (however, therefore, in addition) dikkat edin; eksik cümle bu akışı bozmamalı.",
                "Konudan tamamen kopan veya çok genel/spesifik seçenekleri eleyin."
            ]
        ),
        .irrelevantSentence: TopicContent(
            explanation: "Beş cümleden oluşan bir paragrafta, konu bütünlüğünü bozan (paragrafın ana temasıyla ilgisiz) cümleyi bulmanız istenir.",
            tips: [
                "Paragrafın ana konusunu ilk cümleden belirleyin.",
                "Her cümlenin bu ana konuyla doğrudan ilgili olup olmadığını kontrol edin; farklı bir alt başlığa kayan cümle genelde bozan cümledir.",
                "Bozan cümle bazen konuyla hiç ilgisiz görünmez, 'yakın ama farklı' bir konuya kayar (örneğin bal yerine kahve); dikkatli olun."
            ]
        )
    ]
}
