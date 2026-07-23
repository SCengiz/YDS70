import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            StudyView()
                .tabItem {
                    Label("Çalış", systemImage: "book.fill")
                }

            EzberleView()
                .tabItem {
                    Label("Ezberle", systemImage: "text.book.closed.fill")
                }

            SolveView()
                .tabItem {
                    Label("Çöz", systemImage: "checkmark.circle.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
