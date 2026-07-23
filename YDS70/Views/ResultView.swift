import SwiftUI

struct ResultView: View {
    let correctCount: Int
    let total: Int
    let categoryResults: [QuestionCategory: (correct: Int, total: Int)]
    let title: String
    let onFinishGoHome: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("\(correctCount)/\(total)")
                        .font(.system(size: 48, weight: .bold))
                    Text("Doğru Cevap")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Kategori Bazında Sonuçlar")
                        .font(.headline)
                    ForEach(categoryResults.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                        if let result = categoryResults[category] {
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                Text("\(result.correct)/\(result.total)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Button(action: onFinishGoHome) {
                    Text("Ana Sayfaya Dön")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
