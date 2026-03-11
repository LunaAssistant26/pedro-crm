import AVFoundation
import CoreGraphics
import UIKit

private extension UIImage {
    /// Returns a new image whose underlying pixel data is oriented `.up`.
    ///
    /// Why this exists:
    /// - `UIImage.imageOrientation` is metadata.
    /// - When we later render using `cgImage` into a `CGContext`, that metadata is ignored.
    /// - So we must bake the orientation (and un-mirror if needed) into the pixels.
    func normalizedOrientationUp() -> UIImage {
        guard let cg = self.cgImage else { return self }
        if imageOrientation == .up { return self }

        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)

        // Build a transform that converts the current orientation into `.up`.
        var transform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: w, y: h)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: w, y: 0)
            transform = transform.rotated(by: .pi / 2)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: h)
            transform = transform.rotated(by: -.pi / 2)

        case .up, .upMirrored:
            break

        @unknown default:
            break
        }

        // Remove mirroring (we want a non-mirrored final result).
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: w, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: h, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        let isLeftRight = (imageOrientation == .left || imageOrientation == .leftMirrored || imageOrientation == .right || imageOrientation == .rightMirrored)
        let outSize = isLeftRight ? CGSize(width: h, height: w) : CGSize(width: w, height: h)

        let colorSpace = cg.colorSpace ?? CGColorSpaceCreateDeviceRGB()

        // Use a known-good bitmapInfo to avoid odd alpha/byte-order surprises.
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

        guard let ctx = CGContext(
            data: nil,
            width: Int(outSize.width),
            height: Int(outSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return self
        }

        ctx.concatenate(transform)

        let drawRect = isLeftRight
            ? CGRect(x: 0, y: 0, width: h, height: w)
            : CGRect(x: 0, y: 0, width: w, height: h)

        ctx.draw(cg, in: drawRect)

        guard let newCG = ctx.makeImage() else { return self }
        return UIImage(cgImage: newCG, scale: 1, orientation: .up)
    }
}

/// Generates a simple slideshow video (MP4) from a set of photos.
///
/// Implementation notes:
/// - Uses `AVAssetWriter` + `AVAssetWriterInputPixelBufferAdaptor` (no UI dependencies).
/// - Renders frames with a lightweight crossfade transition between photos.
/// - Supports optional text overlay per frame (e.g. timestamp / coordinate).
/// - Audio is intentionally optional (not included by default) to keep the feature small.
@MainActor
final class RouteVideoGenerator {
    static let shared = RouteVideoGenerator()

    private init() {}

    struct Settings {
        var size: CGSize = CGSize(width: 1080, height: 1080)
        var fps: Int32 = 30
        /// How long each photo is fully visible (seconds). Transition time is added on top.
        var secondsPerPhoto: Double = 2.5
        /// Crossfade duration between photos (seconds).
        var transitionSeconds: Double = 0.45
        /// Optional background color (used for letterboxing).
        var backgroundColor: UIColor = .black

        var totalSecondsPerPhotoIncludingTransition: Double {
            secondsPerPhoto + transitionSeconds
        }
    }

    enum GenerationError: LocalizedError {
        case noImages
        case failedToCreateWriter
        case failedToStartWriting
        case failedToAppendFrame
        case cancelled

        var errorDescription: String? {
            switch self {
            case .noImages: return "No images provided."
            case .failedToCreateWriter: return "Could not create video writer."
            case .failedToStartWriting: return "Could not start writing the video."
            case .failedToAppendFrame: return "Could not append a video frame."
            case .cancelled: return "Video generation cancelled."
            }
        }
    }

    /// Generate an MP4 slideshow video at a temporary URL.
    /// - Parameters:
    ///   - images: Photos to include, in order.
    ///   - overlays: Optional closure that returns a string overlay for the given index.
    ///   - settings: Encoding/render settings.
    ///   - onProgress: Called with 0...1 as frames are appended.
    func generateMP4(
        images: [UIImage],
        overlays: ((Int) -> String?)? = nil,
        settings: Settings = Settings(),
        onProgress: (@MainActor (Double) -> Void)? = nil
    ) async throws -> URL {
        guard !images.isEmpty else { throw GenerationError.noImages }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("route_slideshow_\(UUID().uuidString).mp4")

        // Remove if somehow exists.
        try? FileManager.default.removeItem(at: outputURL)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            throw GenerationError.failedToCreateWriter
        }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(settings.size.width),
            AVVideoHeightKey: Int(settings.size.height)
        ]

        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = false

        let sourceAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: Int(settings.size.width),
            kCVPixelBufferHeightKey as String: Int(settings.size.height),
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourceAttributes)

        guard writer.canAdd(input) else {
            throw GenerationError.failedToCreateWriter
        }
        writer.add(input)

        if !writer.startWriting() {
            throw GenerationError.failedToStartWriting
        }
        writer.startSession(atSourceTime: .zero)

        let fps = Double(settings.fps)
        let framesPerPhoto = Int(round(settings.secondsPerPhoto * fps))
        let framesPerTransition = Int(round(settings.transitionSeconds * fps))
        let totalFrames = max(1, images.count * (framesPerPhoto + framesPerTransition))

        // Normalize orientation up-front to avoid rotated/mirrored frames.
        // Using `cgImage` directly ignores `UIImage.imageOrientation`.
        let prepared = images.map { $0.normalizedOrientationUp() }

        var frameIndex = 0
        var currentTime = CMTime(value: 0, timescale: settings.fps)

        // Helper: create a pixel buffer and render.
        func makePixelBuffer() -> CVPixelBuffer? {
            var pixelBuffer: CVPixelBuffer?
            CVPixelBufferCreate(
                kCFAllocatorDefault,
                Int(settings.size.width),
                Int(settings.size.height),
                kCVPixelFormatType_32BGRA,
                sourceAttributes as CFDictionary,
                &pixelBuffer
            )
            return pixelBuffer
        }

        func drawFrame(into pixelBuffer: CVPixelBuffer, imageA: UIImage, imageB: UIImage?, alphaB: CGFloat, overlayText: String?) {
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }

            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // IMPORTANT: Pixel buffer is 32BGRA. Match byte order + alpha to avoid channel swaps (purple tint).
            let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

            guard let context = CGContext(
                data: baseAddress,
                width: Int(settings.size.width),
                height: Int(settings.size.height),
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return
            }

            // Background.
            context.setFillColor(settings.backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: settings.size))

            func drawImage(_ image: UIImage, alpha: CGFloat) {
                guard let cg = image.cgImage else { return }

                // Aspect-fit.
                let iw = CGFloat(cg.width)
                let ih = CGFloat(cg.height)
                let sw = settings.size.width
                let sh = settings.size.height
                let scale = min(sw / iw, sh / ih)
                let w = iw * scale
                let h = ih * scale
                let x = (sw - w) / 2
                let y = (sh - h) / 2
                let rect = CGRect(x: x, y: y, width: w, height: h)

                context.saveGState()
                context.setAlpha(alpha)
                context.interpolationQuality = .high

                // Draw normally - normalizedOrientationUp() already bakes orientation into pixels.
                // No Y-flip needed since CGContext and pixel buffer coordinates align.
                context.draw(cg, in: rect)
                context.restoreGState()
            }

            drawImage(imageA, alpha: 1.0)
            if let imageB {
                drawImage(imageB, alpha: alphaB)
            }

            if let overlayText, !overlayText.isEmpty {
                // Simple pill overlay at the bottom.
                let padding: CGFloat = 18
                let maxWidth = settings.size.width - padding * 2
                let font = UIFont.systemFont(ofSize: 34, weight: .semibold)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.white
                ]
                let text = NSString(string: overlayText)
                var textRect = text.boundingRect(with: CGSize(width: maxWidth, height: 200), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs, context: nil)
                textRect.size.width = min(maxWidth, ceil(textRect.size.width))
                textRect.size.height = ceil(textRect.size.height)

                let pillRect = CGRect(
                    x: padding,
                    y: settings.size.height - textRect.height - padding * 1.3,
                    width: textRect.width + padding * 1.1,
                    height: textRect.height + padding * 0.8
                )

                context.saveGState()
                context.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
                let path = UIBezierPath(roundedRect: pillRect, cornerRadius: 18)
                context.addPath(path.cgPath)
                context.fillPath()

                // Draw text (flip back to UIKit coordinates).
                UIGraphicsPushContext(context)
                let drawRect = CGRect(x: pillRect.minX + padding * 0.55, y: pillRect.minY + padding * 0.35, width: textRect.width, height: textRect.height)
                text.draw(in: drawRect, withAttributes: attrs)
                UIGraphicsPopContext()
                context.restoreGState()
            }
        }

        // Append frames.
        for i in 0..<prepared.count {
            try Task.checkCancellation()

            let imageA = prepared[i]
            let imageB = (i + 1 < prepared.count) ? prepared[i + 1] : nil

            // Hold.
            for _ in 0..<framesPerPhoto {
                try Task.checkCancellation()
                while !input.isReadyForMoreMediaData {
                    try await Task.sleep(nanoseconds: 5_000_000) // 5ms
                }

                guard let pixelBuffer = makePixelBuffer() else { throw GenerationError.failedToAppendFrame }
                let overlay = overlays?(i)
                drawFrame(into: pixelBuffer, imageA: imageA, imageB: nil, alphaB: 0, overlayText: overlay)
                if !adaptor.append(pixelBuffer, withPresentationTime: currentTime) {
                    throw GenerationError.failedToAppendFrame
                }

                frameIndex += 1
                if let onProgress {
                    onProgress(Double(frameIndex) / Double(totalFrames))
                }

                currentTime = currentTime + CMTime(value: 1, timescale: settings.fps)
            }

            // Transition.
            if let imageB {
                for t in 0..<framesPerTransition {
                    try Task.checkCancellation()
                    while !input.isReadyForMoreMediaData {
                        try await Task.sleep(nanoseconds: 5_000_000)
                    }

                    let alpha = CGFloat(Double(t) / Double(max(1, framesPerTransition - 1)))
                    guard let pixelBuffer = makePixelBuffer() else { throw GenerationError.failedToAppendFrame }

                    // During transition, show the *next* photo's overlay for a nicer feel.
                    let overlay = overlays?(i + 1)
                    drawFrame(into: pixelBuffer, imageA: imageA, imageB: imageB, alphaB: alpha, overlayText: overlay)

                    if !adaptor.append(pixelBuffer, withPresentationTime: currentTime) {
                        throw GenerationError.failedToAppendFrame
                    }

                    frameIndex += 1
                    if let onProgress {
                        onProgress(Double(frameIndex) / Double(totalFrames))
                    }

                    currentTime = currentTime + CMTime(value: 1, timescale: settings.fps)
                }
            }
        }

        input.markAsFinished()

        await withCheckedContinuation { cont in
            writer.finishWriting {
                cont.resume()
            }
        }

        return outputURL
    }
}
