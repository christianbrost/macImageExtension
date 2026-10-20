import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QuickImage")
                .font(.title)
                .bold()

            Text("QuickImage fügt Bildbearbeitung zum Finder-Kontextmenü hinzu. Diese App selbst macht noch nichts – sie dient nur dazu, die Extensions auf deinem Mac zu installieren.")
                .fixedSize(horizontal: false, vertical: true)

            Text("Aktivieren:")
                .font(.headline)
            Text("Rechtsklick auf eine Bilddatei im Finder → Dienste → Dienste-Einstellungen … → „In PNG konvertieren“ aktivieren.")
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(width: 420)
    }
}

#Preview {
    ContentView()
}
