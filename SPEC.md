# Projekt: Mac-Bildtool (Arbeitstitel "QuickImage")

## Ziel
Eine native macOS-App, die Bildbearbeitung direkt über das Finder-Kontextmenü
ermöglicht: Rechtsklick (bzw. Control+Klick) auf eine oder mehrere Bilddateien
→ Menü mit Aktionen wie Konvertieren, Skalieren, Zuschneiden. Ohne erst
Vorschau oder ein anderes Programm öffnen zu müssen.

## Kontext
- Ich bin Informatikstudent und mache dieses Projekt bewusst als
  Vibe-Coding-Experiment: Du schreibst den Code, ich treffe die Entscheidungen,
  reviewe und teste.
- Ich habe noch keine Erfahrung mit Swift, SwiftUI oder macOS-Extensions.
  Erkläre wichtige Entscheidungen deshalb kurz und verständlich, aber ohne
  Romane.
- Gerät: MacBook Air M5 mit aktuellem macOS. Die App ist zunächst nur für mich
  (kein App Store, keine Notarisierung nötig).

## Tech-Stack
- Swift + SwiftUI, Xcode-Projekt
- Bildverarbeitung bevorzugt mit Apple-Frameworks (ImageIO, Core Image, Vision)
- Externe Abhängigkeiten nur wenn nötig (z. B. für WebP-Export), dann per
  Swift Package Manager

## Features nach Phasen
**Phase 1 (MVP):** Finder-Kontextmenü → "Konvertieren in…" PNG / JPEG / HEIC / WebP.
Die neue Datei wird neben dem Original gespeichert, das Original bleibt unverändert.

**Phase 2:** Skalieren (Pixelmaße oder Prozent, Seitenverhältnis beibehalten)
und Komprimierung mit Qualitätsregler inkl. Anzeige der Dateigröße vorher/nachher.

**Phase 3:** Zuschneiden in einem kleinen Fenster mit festen Seitenverhältnissen
(frei, 1:1, 4:5, 16:9).

**Phase 4 (optional):** Batch-Verarbeitung mehrerer Dateien, Metadaten (EXIF/GPS)
entfernen, Hintergrund entfernen mit dem Vision-Framework, AVIF-Export.

## Offene technische Fragen (bitte zuerst recherchieren und mir Optionen vorschlagen)
1. Welcher Weg ins Finder-Kontextmenü ist am sinnvollsten: Finder Sync
   Extension, Action Extension, Quick Action/Service? Vor- und Nachteile kurz.
2. Welche Formate kann ImageIO auf aktuellem macOS schreiben, und was brauche
   ich zusätzlich für WebP?
3. Wie öffne ich aus der Extension heraus ein Fenster (z. B. fürs Zuschneiden)?
4. Was muss ich bei Sandboxing, Dateiberechtigungen und Signierung beachten?

## Entscheidungen (Phase 1)
1. **Weg ins Finder-Kontextmenü:** Ursprünglich als Action Extension
   (PlugInKit/ExtensionKit, erscheint unter "Schnellaktionen") geplant und
   umgesetzt. Auf diesem Rechner (macOS-Beta "Golden Gate", SDK macOS 27,
   Build 26A425) hängt Finders XPC-Handshake zur Extension zuverlässig nach
   60 Sekunden ("Die Kommunikation mit einem Hilfsprogramm ist fehlgeschlagen"),
   bestätigt per Console-Logging auf beiden Seiten (Finder- und
   Extension-Prozess) — kein Fehler in unserem Code, da `beginRequest` nie
   aufgerufen wird. Ein Test mit dem klassischen Dienste-Menü (NSServices)
   funktionierte sofort zuverlässig. Deshalb: Phase 1 nutzt NSServices
   ("Dienste"-Menü im Finder-Kontextmenü) statt einer Action Extension.
   Die Action-Extension-Variante kann bei Bedarf später erneut versucht
   werden, falls ein OS-Update das Problem behebt.
2. **Formate via ImageIO:** `CGImageSourceCreateWithURL` /
   `CGImageDestinationCreateWithURL` lesen und schreiben PNG, JPEG, HEIC
   nativ. WebP kann ImageIO nur lesen, nicht schreiben — dafür wird das SPM-
   Paket `ainame/Swift-WebP` (dünner libwebp-Wrapper) eingebunden.
3. **Sandboxing:** App Sandbox wurde deaktiviert. Mit Sandbox erlaubte
   `com.apple.security.files.user-selected.read-write` nur Zugriff auf die
   exakt ausgewählte Datei, nicht das Schreiben einer neuen Datei im selben
   Ordner (`CGImageDestinationCreateWithURL` lieferte `nil`). Da die App nur
   für den persönlichen Gebrauch ist (kein App Store, keine Notarisierung),
   ist das unproblematisch.

## Arbeitsregeln
- Stell mir zuerst Fragen, wenn etwas unklar ist, bevor du planst.
- Arbeite in kleinen Schritten. Jede Phase erst planen, dann umsetzen.
- Nach jeder Änderung bauen (xcodebuild) und Fehler selbst beheben.
- Wenn ein Schritt nur manuell in Xcode oder den Systemeinstellungen geht
  (Signing Team, Extension aktivieren usw.), sag mir genau, was ich klicken muss.
- Nach jedem funktionierenden Schritt einen Git-Commit mit klarer Nachricht
  vorschlagen.
- Halte eine README.md aktuell: was die App kann, wie man sie baut, und
  einen Abschnitt "Wie entstanden", da das Projekt ins GitHub-Portfolio kommt.
- Keine Features außerhalb der aktuellen Phase einbauen.

## Git-Workflow

### Branches
- Arbeite nie direkt auf `main`. `main` enthält nur fertige, getestete Features.
- Lege für jedes Feature einen eigenen Branch von `main` an,
  benannt nach dem Schema `feature/<kurzer-name>` (z. B. `feature/convert`,
  `feature/crop`). Für Bugfixes: `fix/<kurzer-name>`.
- Bevor du einen neuen Branch anlegst: prüfe mit `git status`, dass keine
  uncommitteten Änderungen offen sind.

### Commits (lokal, auf dem Feature-Branch)
- Committe lokal, sobald ein Arbeitsschritt fertig ist und das Projekt
  fehlerfrei baut. Lieber oft und klein als selten und groß.
- Committe niemals einen Stand, der nicht baut.
- Commit-Nachrichten auf Englisch, im Imperativ, kurz und konkret
  (z. B. "Add PNG export to conversion service").

### Push
- Pushe den Feature-Branch nur, wenn ich darum bitte oder am Ende einer
  Sitzung, nachdem du mich gefragt hast.
- Niemals `git push --force` oder History umschreiben, ohne mich vorher
  zu fragen.

### Merge in main (Squash)
- Ein Feature wird erst gemergt, wenn ich es selbst getestet und
  freigegeben habe. Merge niemals eigenständig.
- Nach meiner Freigabe: Squash-Merge in `main`, sodass pro Feature genau
  ein Commit in `main` landet:
    git checkout main
    git pull
    git merge --squash feature/<name>
    git commit -m "<Zusammenfassung des Features>"
    git push
- Die Squash-Commit-Nachricht fasst das ganze Feature zusammen
  (z. B. "Add image conversion via Finder context menu"),
  optional mit kurzen Stichpunkten im Body.
- Danach den Feature-Branch lokal und auf GitHub löschen
  (`git branch -D feature/<name>` und `git push origin --delete feature/<name>`).
  `-D` ist nötig, weil Git squash-gemergte Branches nicht als gemergt erkennt.

### Sonstiges
- Halte eine passende `.gitignore` für Xcode/Swift aktuell
  (u. a. `DerivedData/`, `xcuserdata/`, `.DS_Store`, `*.xcuserstate`).
- Keine Zugangsdaten, Zertifikate oder Signierungsdateien committen.
