import AppKit
import os.log

private let log = Logger(subsystem: "dev.christianbrost.quickimage", category: "ServiceProvider")

/// Vends QuickImage's Finder actions via the classic Services menu.
///
/// Action Extensions (PlugInKit/ExtensionKit, i.e. Finder "Schnellaktionen") were tried
/// first per SPEC.md's original plan, but on this machine's macOS beta the extension
/// process never receives the request (Finder's XPC handshake to it times out after
/// 60s, confirmed via Console logging). The classic NSServices mechanism works
/// reliably, so Phase 1 uses it instead. See SPEC.md for the full writeup.
class ServiceProvider: NSObject {
    @objc func convertToPNG(_ pasteboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let filenames = pasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] else {
            log.error("No filenames found on pasteboard")
            error.pointee = "Keine Dateien gefunden"
            return
        }

        for path in filenames {
            let url = URL(fileURLWithPath: path)
            do {
                try ImageConverter.convertToPNG(fileAt: url)
            } catch {
                log.error("Conversion failed for \(url.lastPathComponent, privacy: .public): \(String(describing: error), privacy: .public)")
            }
        }
    }
}
