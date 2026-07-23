import SwiftUI
import UniformTypeIdentifiers

struct VocabImportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pastedText: String = ""
    @State private var isShowingFileImporter = false
    @State private var resultMessage: String?
    @State private var skippedLines: [String] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Her satıra bir kelime olacak şekilde İngilizce - Türkçe kelime çiftlerini yapıştır (aralarına tire, iki nokta veya sekme koyabilirsin). İstersen bunun yerine bir PDF de yükleyebilirsin.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                TextEditor(text: $pastedText)
                    .font(.callout)
                    .frame(minHeight: 220)
                    .padding(8)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                Button {
                    isShowingFileImporter = true
                } label: {
                    Label("PDF Yükle", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                if let resultMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(resultMessage)
                            .font(.subheadline.weight(.medium))
                        if !skippedLines.isEmpty {
                            Text("Anlaşılamayan satırlar:")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            ForEach(skippedLines.prefix(10), id: \.self) { line in
                                Text(line)
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
                    Text("Listelere Ekle")
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
            .navigationTitle("Kelime Listesi Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    loadPDF(at: url)
                case .failure:
                    resultMessage = "Dosya okunamadı."
                    skippedLines = []
                }
            }
        }
    }

    private var canImport: Bool {
        !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadPDF(at url: URL) {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

        if let text = VocabImporter.extractText(fromPDF: url) {
            pastedText = text
            resultMessage = nil
            skippedLines = []
        } else {
            resultMessage = "PDF içinden metin okunamadı."
            skippedLines = []
        }
    }

    private func processImport() {
        let (words, skipped) = VocabImporter.parse(text: pastedText)
        let result = VocabBank.shared.addWords(words)
        skippedLines = skipped

        var message = "\(result.added) yeni kelime eklendi."
        if result.duplicates > 0 {
            message += " \(result.duplicates) kelime zaten listede olduğu için eklenmedi."
        }
        if !skipped.isEmpty {
            message += " \(skipped.count) satır anlaşılamadı."
        }
        resultMessage = message
    }
}
