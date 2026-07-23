import SwiftUI

struct SolveView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Çöz — Yakında",
                systemImage: "checkmark.circle",
                description: Text("Bu sekme daha sonra tanımlanacak.")
            )
            .navigationTitle("Çöz")
        }
    }
}
