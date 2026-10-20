# QuickImage

Eine native macOS-App, die Bildbearbeitung direkt über das Finder-Kontextmenü
ermöglicht (Konvertieren, Skalieren, Zuschneiden) — ohne erst Vorschau oder
ein anderes Programm öffnen zu müssen.

Siehe [SPEC.md](./SPEC.md) für die vollständige Projektspezifikation.

## Status

🚧 In Entwicklung — Phase 1 (Konvertierung PNG/JPEG/HEIC/WebP).
PNG-Konvertierung über das Dienste-Menü funktioniert; JPEG/HEIC/WebP folgen.

## Build

```
cd QuickImage
xcodegen generate
xcodebuild -project QuickImage.xcodeproj -scheme QuickImage -configuration Debug build
```

Danach `QuickImage.app` nach `/Applications` kopieren und einmal starten,
damit sich der Dienst registriert. Danach im Finder: Rechtsklick auf eine
Bilddatei → Dienste → Dienste-Einstellungen … → „In PNG konvertieren"
aktivieren.

## Wie entstanden

_(folgt)_
