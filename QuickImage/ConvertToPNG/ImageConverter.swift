import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageConverterError: Error {
    case cannotRead
    case cannotWrite
}

/// Temporary home for the conversion logic during the Phase 1 spike.
/// Gets extracted into a shared `ImageConversionKit` package once the
/// Action Extension's file I/O behavior is confirmed to work (step 4).
enum ImageConverter {
    static func convertToPNG(fileAt url: URL) throws {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageConverterError.cannotRead
        }

        let destinationURL = uniqueURL(
            forBase: url.deletingPathExtension(),
            extension: "png"
        )

        guard let destination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            throw ImageConverterError.cannotWrite
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw ImageConverterError.cannotWrite
        }
    }

    private static func uniqueURL(forBase base: URL, extension ext: String) -> URL {
        var candidate = base.appendingPathExtension(ext)
        var counter = 1
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = base.appendingPathExtension("\(counter)").appendingPathExtension(ext)
            counter += 1
        }
        return candidate
    }
}
