import SwiftUI

struct ResultView: View {
    let correctCount: Int
    let total: Int
    let categoryResults: [QuestionCategory: (correct: Int, total: Int)]
    let title: String
    let onFinishGoHome: () -> Void

    private var percentage: Double {
        total == 0 ? 0 : Double(correctCount) / Double(total)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color(.secondarySystemBackground), lineWidth: 14)
                    Circle()
                        .trim(from: 0, to: percentage)
                        .stroke(
                            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(correctCount)/\(total)")
                            .font(.system(size: 34, weight: .bold))
                        Text("Doğru Cevap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                .padding(.top, 32)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Kategori Bazında Sonuçlar")
                        .font(.headline)
                    ForEach(categoryResults.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                        if let result = categoryResults[category] {
                            HStack(spacing: 10) {
                                Image(systemName: CategoryStyle.icon(for: category))
                                    .font(.caption)
                                    .foregroundStyle(CategoryStyle.color(for: category))
                                    .frame(width: 22)
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
                        .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
