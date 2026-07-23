import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct VocabImportView: View {
    private enum Stage {
        case pickingMethod
        case reviewing
    }

    @Environment(\.dismiss) private var dismiss

    @State private var stage: Stage = .pickingMethod
    @State private var pastedText: String = ""
    @State private var isProcessing = false
    @State private var isShowingFileImporter = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var resultMessage: String?
    @State private var skippedLines: [String] = []

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .pickingMethod:
                    methodPicker
                case .reviewing:
                    reviewScreen
                }
            }
            .navigationTitle("Kelime Listesi Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if stage == .reviewing {
                        Button("Geri") {
                            resultMessage = nil
                            skippedLines = []
                            stage = .pickingMethod
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
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task { await loadImage(from: newItem) }
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

    // MARK: - Method picker

    private var methodPicker: some View {
        VStack(spacing: 16) {
            Text("Kelime listesini nasıl eklemek istersin?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            methodCard(
                icon: "text.alignleft",
                title: "Metin ile Yükle",
                subtitle: "İngilizce - Türkçe kelime çiftlerini yapıştır",
                colors: [.blue, .indigo]
            ) {
                pastedText = ""
                stage = .reviewing
            }

            methodCard(
                icon: "doc.badge.plus",
                title: "PDF Yükle",
                subtitle: "Bir PDF dosyası seç",
                colors: [.orange, .pink]
            ) {
                isShowingFileImporter = true
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                methodCardLabel(
                    icon: "photo.badge.plus",
                    title: "Görsel ile Yükle",
                    subtitle: "Bir kelime listesi ekran görüntüsü seç",
                    colors: [.green, .teal]
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }

    private func methodCard(icon: String, title: String, subtitle: String, colors: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            methodCardLabel(icon: icon, title: title, subtitle: subtitle, colors: colors)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private func methodCardLabel(icon: String, title: String, subtitle: String, colors: [Color]) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Review screen

    private var reviewScreen: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Çıkarılan metni kontrol et, gerekirse düzelt. Her satırda bir kelime olmalı (terim ve anlam arasına tire, iki nokta veya sekme koyabilirsin).")
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

        if let text = VocabImporter.extractText(fromPDF: url) {
            pastedText = text
            resultMessage = nil
            skippedLines = []
            stage = .reviewing
        } else {
            pastedText = ""
            resultMessage = "PDF içinden metin okunamadı."
            skippedLines = []
            stage = .reviewing
        }
    }

    private func loadImage(from item: PhotosPickerItem) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            pastedText = ""
            resultMessage = "Görsel okunamadı."
            skippedLines = []
            stage = .reviewing
            return
        }

        if let text = await VocabImporter.extractText(fromImage: uiImage) {
            pastedText = text
        } else {
            pastedText = ""
            resultMessage = "Görselden metin okunamadı."
        }
        skippedLines = []
        stage = .reviewing
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
