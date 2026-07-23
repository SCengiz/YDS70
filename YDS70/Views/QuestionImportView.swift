import SwiftUI
import UniformTypeIdentifiers

struct QuestionImportView: View {
    private enum Stage {
        case start
        case reviewing
    }

    @Environment(\.dismiss) private var dismiss

    @State private var stage: Stage = .start
    @State private var pastedText: String = ""
    @State private var isProcessing = false
    @State private var isShowingFileImporter = false
    @State private var resultMessage: String?
    @State private var skippedBlocks: [String] = []

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .start:
                    startScreen
                case .reviewing:
                    reviewScreen
                }
            }
            .navigationTitle("Soru Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if stage == .reviewing {
                        Button("Geri") {
                            resultMessage = nil
                            skippedBlocks = []
                            stage = .start
                        }
                    } else {
                        Button("Kapat") { dismiss() }
                    }
                }
            }
            .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    loadPDF(at: url)
                case .failure:
                    resultMessage = "Dosya okunamadı."
                }
            }
            .overlay {
                if isProcessing {
                    ProgressView("İşleniyor…")
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Start screen

    private var startScreen: some View {
        VStack(spacing: 16) {
            Text("Kendi hazırladığın/derlediğin soruları içeren bir PDF yükle.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .padding(.horizontal)

            Button {
                isShowingFileImporter = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(
                            LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PDF Yükle").font(.body.weight(.semibold))
                        Text("Bir PDF dosyası seç").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                Text("Beklenen biçim")
                    .font(.caption.weight(.semibold))
                Text("1. Soru metni...\nA) seçenek\nB) seçenek\nC) seçenek\n...\n\nCEVAP ANAHTARI\n1) B\n2) A\n...")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - Review screen

    private var reviewScreen: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Çıkarılan metni kontrol et, gerekirse düzelt. Her soru bir numarayla başlamalı, seçenekler A) B) C)... ile, doğru cevaplar en sonda CEVAP ANAHTARI listesiyle belirtilmeli.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            TextEditor(text: $pastedText)
                .font(.callout)
                .frame(minHeight: 260)
                .padding(8)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            if let resultMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(resultMessage)
                        .font(.subheadline.weight(.medium))
                    if !skippedBlocks.isEmpty {
                        Text("Eklenemeyen sorular:")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                        ForEach(skippedBlocks.prefix(10), id: \.self) { block in
                            Text(block)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            Spacer()

            Button {
                processImport()
            } label: {
                Text("Sorulara Ekle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canImport ? Color.accentColor : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canImport)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
    }

    private var canImport: Bool {
        !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    private func loadPDF(at url: URL) {
        isProcessing = true
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess { url.stopAccessingSecurityScopedResource() }
            isProcessing = false
        }

        if let text = DocumentTextExtractor.extractText(fromPDF: url) {
            pastedText = text
            resultMessage = nil
            skippedBlocks = []
            stage = .reviewing
        } else {
            pastedText = ""
            resultMessage = "PDF içinden metin okunamadı."
            skippedBlocks = []
            stage = .reviewing
        }
    }

    private func processImport() {
        let (questions, skipped) = QuestionImporter.parse(text: pastedText)
        QuestionBank.shared.addUserQuestions(questions)
        skippedBlocks = skipped

        var message = "\(questions.count) soru eklendi."
        if !skipped.isEmpty {
            message += " \(skipped.count) soru anlaşılamadı."
        }
        resultMessage = message
    }
}
