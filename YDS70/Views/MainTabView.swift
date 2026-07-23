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
                    Label("Ezberle", systemImage: "brain.head.profile")
                }

            SolveView()
                .tabItem {
                    Label("Çöz", systemImage: "pencil.and.checkmark")
                }
        }
    }
}

#Preview {
    MainTabView()
}
