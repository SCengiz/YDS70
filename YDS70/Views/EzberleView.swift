import SwiftUI

struct EzberleView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VocabTopicView(path: $path)
                .navigationDestination(for: VocabRoute.self) { route in
                    switch route {
                    case .vocabPractice(let words, let title):
                        VocabPracticeView(words: words, title: title)
                    case .masteredWords:
                        MasteredWordsView()
                    }
                }
        }
    }
}
