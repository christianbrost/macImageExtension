import Foundation
import UniformTypeIdentifiers
import os.log

private let log = Logger(subsystem: "dev.christianbrost.quickimage.ConvertToPNG", category: "ActionRequestHandler")

/// Spike: validates that an Action Extension can write a new file next to the
/// original, not just replace it in place. See SPEC.md Phase 1, step 3.
class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        guard let items = context.inputItems as? [NSExtensionItem] else {
            context.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        let providers = items.flatMap { $0.attachments ?? [] }
            .filter { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }

        guard !providers.isEmpty else {
            context.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, _, error in
                defer { group.leave() }
                guard let url, error == nil else {
                    log.error("Failed to load file representation: \(String(describing: error))")
                    return
                }
                do {
                    try ImageConverter.convertToPNG(fileAt: url)
                } catch {
                    log.error("Conversion failed for \(url.lastPathComponent, privacy: .public): \(String(describing: error))")
                }
            }
        }

        group.notify(queue: .main) {
            context.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
