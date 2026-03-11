import AVFoundation
import CoreGraphics
import CoreLocation
import MapKit
import Photos
import UIKit

/// Generates the "Muter Video" (vertical 1080x1920 MP4) for a completed walk.
///
/// Output style (MVP):
/// - A map snapshot of the whole route with the route polyline + numbered photo markers
/// - A small walking dot that moves between photo stops
/// - At each stop: a zoom-in on the map → Look Around (if available) → crossfade to the user's photo (Ken Burns)
/// - Export helper to save to Photos.
@MainActor
final class MuterVideoGenerator {
    static let shared = MuterVideoGenerator()
    private init() {}

    struct PhotoStop {
        let coordinate: CLLocationCoordinate2D
        let image: UIImage
        let title: String
    }

    struct Settings {
        var size: CGSize = CGSize(width: 1080, height: 1920)
        var fps: Int32 = 30

        // Timing
        var startHold: Double = 1.4
        var walkSecondsPerLeg: Double = 1.2
        var zoomSeconds: Double = 0.45
        var lookAroundHold: Double = 5.0
        var crossfadeSeconds: Double = 0.45
        var photoHold: Double = 5.0
        var zoomOutSeconds: Double = 0.45
        var endHold: Double = 1.0

        var backgroundColor: UIColor = .black
        var routeStrokeColor: UIColor = .systemTeal

        // Styling
        var routeLineWidth: CGFloat = 6
        var dotRadius: CGFloat = 9
    }

    enum GenerationError: LocalizedError {
        case noStops
        case failedToCreateWriter
        case failedToStartWriting
        case failedToAppendFrame
        case failedToMakeMapSnapshot
        case cancelled

        var errorDescription: String? {
            switch self {
            case .noStops: return "No photo stops available."
            case .failedToCreateWriter: return "Could not create video writer."
            case .failedToStartWriting: return "Could not start writing the video."
            case .failedToAppendFrame: return "Could not append a video frame."
            case .failedToMakeMapSnapshot: return "Could not create map snapshot."
            case .cancelled: return "Video generation cancelled."
            }
        }
    }

    /// Generate a Muter Video MP4 at a temporary URL.
    func generateMP4(
        routeCoordinates: [CLLocationCoordinate2D],
        stops: [PhotoStop],
        settings: Settings = Settings(),
        onProgress: (@MainActor (Double) -> Void)? = nil
    ) async throws -> URL {
        guard !stops.isEmpty else { throw GenerationError.noStops }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("muter_video_\(UUID().uuidString).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        // Prepare assets up front.
        let mapSnapshot = try await makeRouteMapSnapshot(
            routeCoordinates: routeCoordinates,
            stops: stops,
            settings: settings
        )

        // Pre-fetch Look Around stills (best-effort).
        var lookAroundImages: [UIImage?] = Array(repeating: nil, count: stops.count)
        if #available(iOS 16.0, *) {
            await withTaskGroup(of: (Int, UIImage?).self) { group in
                for (idx, stop) in stops.enumerated() {
                    group.addTask {
                        let img = await Self.fetchLookAroundImage(at: stop.coordinate, size: settings.size)
                        return (idx, img)
                    }
                }
                for await (idx, img) in group {
                    lookAroundImages[idx] = img
                }
            }
        }

        // Writer setup (based on RouteVideoGenerator).
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

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: sourceAttributes
        )

        guard writer.canAdd(input) else { throw GenerationError.failedToCreateWriter }
        writer.add(input)

        guard writer.startWriting() else { throw GenerationError.failedToStartWriting }
        writer.startSession(atSourceTime: .zero)

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

        // Timeline helpers.
        let fpsD = Double(settings.fps)
        func frames(_ seconds: Double) -> Int { Int(max(1, round(seconds * fpsD))) }

        // Rough total frame count for progress.
        let legs = max(1, stops.count) + 1
        let totalSeconds = settings.startHold
        + Double(legs) * settings.walkSecondsPerLeg
        + Double(stops.count) * (settings.zoomSeconds + settings.lookAroundHold + settings.crossfadeSeconds + settings.photoHold + settings.zoomOutSeconds)
        + settings.endHold
        let totalFrames = max(1, Int(round(totalSeconds * fpsD)))

        var frameIndex = 0
        var currentTime = CMTime(value: 0, timescale: settings.fps)

        func appendFrame(render: (CGContext) -> Void) async throws {
            try Task.checkCancellation()
            while !input.isReadyForMoreMediaData {
                try await Task.sleep(nanoseconds: 5_000_000)
            }

            guard let pixelBuffer = makePixelBuffer() else { throw GenerationError.failedToAppendFrame }

            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                throw GenerationError.failedToAppendFrame
            }

            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            // Force sRGB to avoid wide‑gamut / color cast issues (e.g. magenta tint) when compositing.
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

            // IMPORTANT: Pixel buffer is 32BGRA. We must match that in the CGContext bitmapInfo,
            // otherwise channels can be interpreted incorrectly (common symptom: strong blue/magenta cast).
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
                throw GenerationError.failedToAppendFrame
            }

            // Fill background.
            context.setFillColor(settings.backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: settings.size))

            // Use UIKit-style coordinates (origin top-left, y-down) for all drawing,
            // which matches MKMapSnapshotter point(for:) and UIKit text/image APIs.
            context.saveGState()
            context.translateBy(x: 0, y: settings.size.height)
            context.scaleBy(x: 1, y: -1)
            render(context)
            context.restoreGState()

            guard adaptor.append(pixelBuffer, withPresentationTime: currentTime) else {
                throw GenerationError.failedToAppendFrame
            }

            frameIndex += 1
            if let onProgress { onProgress(Double(frameIndex) / Double(totalFrames)) }
            currentTime = currentTime + CMTime(value: 1, timescale: settings.fps)
        }

        func drawOverlayLabel(_ text: String?, in context: CGContext) {
            guard let text, !text.isEmpty else { return }
            let padding: CGFloat = 18
            let maxWidth = settings.size.width - padding * 2

            let font = UIFont.systemFont(ofSize: 40, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]

            let ns = NSString(string: text)
            var textRect = ns.boundingRect(
                with: CGSize(width: maxWidth, height: 200),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            )
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
            context.addPath(UIBezierPath(roundedRect: pillRect, cornerRadius: 18).cgPath)
            context.fillPath()

            UIGraphicsPushContext(context)
            ns.draw(in: CGRect(
                x: pillRect.minX + padding * 0.55,
                y: pillRect.minY + padding * 0.35,
                width: textRect.width,
                height: textRect.height
            ), withAttributes: attrs)
            UIGraphicsPopContext()
            context.restoreGState()
        }

        func drawUIImage(_ image: UIImage, alpha: CGFloat = 1.0, transform: CGAffineTransform = .identity, in context: CGContext) {
            let sw = settings.size.width
            let sh = settings.size.height

            context.saveGState()
            context.concatenate(transform)
            context.setAlpha(alpha)
            context.interpolationQuality = .high

            // Use UIKit drawing to respect UIImage orientation metadata.
            UIGraphicsPushContext(context)
            image.draw(in: CGRect(x: 0, y: 0, width: sw, height: sh))
            UIGraphicsPopContext()

            context.restoreGState()
        }

        func aspectFitRect(for image: UIImage, in bounds: CGRect) -> CGRect {
            let iw = max(1, image.size.width)
            let ih = max(1, image.size.height)
            let bw = max(1, bounds.width)
            let bh = max(1, bounds.height)

            let scale = min(bw / iw, bh / ih)
            let w = iw * scale
            let h = ih * scale
            return CGRect(
                x: bounds.midX - w / 2,
                y: bounds.midY - h / 2,
                width: w,
                height: h
            )
        }

        func drawKenBurns(_ image: UIImage, t: CGFloat, in context: CGContext) {
            // Respect original photo orientation/aspect: draw aspect-fit inside the vertical canvas.
            let bounds = CGRect(origin: .zero, size: settings.size)
            let fit = aspectFitRect(for: image, in: bounds)

            // Gentle scale + pan within the fit rect.
            let minScale: CGFloat = 1.0
            let maxScale: CGFloat = 1.10
            let s = minScale + (maxScale - minScale) * t

            // Small pan (kept subtle to avoid exposing black bars too much).
            let dx: CGFloat = -0.04 * fit.width * t
            let dy: CGFloat = -0.06 * fit.height * t

            context.saveGState()
            context.addRect(bounds)
            context.clip()

            let cx = fit.midX
            let cy = fit.midY
            let transform = CGAffineTransform(translationX: dx, y: dy)
                .translatedBy(x: cx, y: cy)
                .scaledBy(x: s, y: s)
                .translatedBy(x: -cx, y: -cy)
            context.concatenate(transform)

            UIGraphicsPushContext(context)
            image.draw(in: fit)
            UIGraphicsPopContext()

            context.restoreGState()
        }

        // Pre-rendered base map image (already at target size).
        let baseMap = mapSnapshot.image

        // Precompute snapshot screen points for the full route + each stop.
        let routePoints: [CGPoint] = routeCoordinates.map { mapSnapshot.point(for: $0) }
        let stopPoints: [CGPoint] = stops.map { mapSnapshot.point(for: $0.coordinate) }

        func nearestRouteIndex(to coordinate: CLLocationCoordinate2D) -> Int {
            guard !routeCoordinates.isEmpty else { return 0 }
            var bestI = 0
            var bestD = CLLocation(latitude: routeCoordinates[0].latitude, longitude: routeCoordinates[0].longitude)
                .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            for i in 1..<routeCoordinates.count {
                let d = CLLocation(latitude: routeCoordinates[i].latitude, longitude: routeCoordinates[i].longitude)
                    .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                if d < bestD {
                    bestD = d
                    bestI = i
                }
            }
            return bestI
        }

        func sampleAlongPolyline(points: [CGPoint], t: CGFloat) -> (point: CGPoint, heading: CGFloat) {
            guard points.count >= 2 else {
                return (points.first ?? CGPoint(x: settings.size.width / 2, y: settings.size.height / 2), 0)
            }

            // Cumulative lengths.
            var segLengths: [CGFloat] = []
            segLengths.reserveCapacity(points.count - 1)
            var total: CGFloat = 0
            for i in 0..<(points.count - 1) {
                let a = points[i]
                let b = points[i + 1]
                let l = hypot(b.x - a.x, b.y - a.y)
                segLengths.append(l)
                total += l
            }
            if total <= 0.001 {
                let a = points[0]
                let b = points[1]
                return (a, atan2(b.y - a.y, b.x - a.x))
            }

            let target = max(0, min(1, t)) * total
            var run: CGFloat = 0
            for i in 0..<(points.count - 1) {
                let l = segLengths[i]
                if run + l >= target {
                    let localT = (l <= 0.001) ? 0 : (target - run) / l
                    let a = points[i]
                    let b = points[i + 1]
                    let p = CGPoint(x: a.x + (b.x - a.x) * localT, y: a.y + (b.y - a.y) * localT)
                    let heading = atan2(b.y - a.y, b.x - a.x)
                    return (p, heading)
                }
                run += l
            }
            let a = points[points.count - 2]
            let b = points[points.count - 1]
            return (b, atan2(b.y - a.y, b.x - a.x))
        }

        func drawWalker(at point: CGPoint, heading: CGFloat, stepPhase: CGFloat, in ctx: CGContext) {
            // A tiny "traveler" glyph (head/body/legs + backpack) drawn procedurally.
            // Designed to read well at small sizes and survive compression.
            let scale: CGFloat = 1.0
            let size: CGFloat = max(14, settings.dotRadius * 2.2) * scale

            ctx.saveGState()
            ctx.translateBy(x: point.x, y: point.y)
            ctx.rotate(by: heading)

            // Shadow/outline
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)

            let outline = UIColor.black.withAlphaComponent(0.35).cgColor
            let fill = UIColor.white.cgColor

            // Head
            let headR: CGFloat = size * 0.18
            let headC = CGPoint(x: 0, y: -size * 0.28)
            ctx.setFillColor(fill)
            ctx.setStrokeColor(outline)
            ctx.setLineWidth(2)
            ctx.addEllipse(in: CGRect(x: headC.x - headR, y: headC.y - headR, width: headR * 2, height: headR * 2))
            ctx.drawPath(using: .fillStroke)

            // Body
            ctx.setStrokeColor(fill)
            ctx.setLineWidth(3)
            ctx.move(to: CGPoint(x: 0, y: -size * 0.12))
            ctx.addLine(to: CGPoint(x: 0, y: size * 0.18))
            ctx.strokePath()

            // Backpack
            ctx.setFillColor(fill)
            ctx.setStrokeColor(outline)
            ctx.setLineWidth(2)
            let pack = CGRect(x: -size * 0.18, y: -size * 0.10, width: size * 0.22, height: size * 0.26)
            let packPath = UIBezierPath(roundedRect: pack, cornerRadius: 4)
            ctx.addPath(packPath.cgPath)
            ctx.drawPath(using: .fillStroke)

            // Legs (animated)
            let stride = sin(stepPhase * .pi * 2) * (size * 0.10)
            ctx.setStrokeColor(fill)
            ctx.setLineWidth(3)
            ctx.move(to: CGPoint(x: 0, y: size * 0.18))
            ctx.addLine(to: CGPoint(x: -size * 0.14, y: size * 0.42 + stride))
            ctx.strokePath()
            ctx.move(to: CGPoint(x: 0, y: size * 0.18))
            ctx.addLine(to: CGPoint(x: size * 0.14, y: size * 0.42 - stride))
            ctx.strokePath()

            // Tiny pin-tip under feet for readability
            ctx.setFillColor(outline)
            ctx.addEllipse(in: CGRect(x: -2.5, y: size * 0.45, width: 5, height: 5))
            ctx.fillPath()

            ctx.restoreGState()
        }

        func drawMapWithDot(dotPoint: CGPoint, heading: CGFloat = 0, stepPhase: CGFloat = 0, zoomScale: CGFloat = 1.0, zoomCenter: CGPoint? = nil, label: String? = nil) async throws {
            // Render one frame.
            try await appendFrame { ctx in
                let center = zoomCenter ?? CGPoint(x: settings.size.width / 2, y: settings.size.height / 2)
                // Transform that zooms around `center` in image coordinates.
                let t = CGAffineTransform(translationX: center.x, y: center.y)
                    .scaledBy(x: zoomScale, y: zoomScale)
                    .translatedBy(x: -center.x, y: -center.y)

                drawUIImage(baseMap, transform: t, in: ctx)

                // Walking figure.
                let pt = dotPoint.applying(t)
                drawWalker(at: pt, heading: heading, stepPhase: stepPhase, in: ctx)

                drawOverlayLabel(label, in: ctx)
            }
        }

        // START hold on map.
        let startPoint = stopPoints.first ?? CGPoint(x: settings.size.width / 2, y: settings.size.height / 2)
        for _ in 0..<frames(settings.startHold) {
            try await drawMapWithDot(dotPoint: startPoint, label: "Start")
        }

        // Walk legs along the *actual* route polyline (smooth interpolation, no teleporting).
        // We map each stop to its nearest route index, then animate between indices.
        let stopRouteIndices: [Int] = stops.map { nearestRouteIndex(to: $0.coordinate) }

        // Build route index legs: start (0) -> stop1 -> stop2 ... -> end (last).
        let endRouteIndex = max(0, routePoints.count - 1)
        var legIndexPairs: [(Int, Int)] = []
        var prev = 0
        for idx in stopRouteIndices {
            legIndexPairs.append((prev, idx))
            prev = idx
        }
        legIndexPairs.append((prev, endRouteIndex))

        for legIndex in 0..<legIndexPairs.count {
            let (i0, i1) = legIndexPairs[legIndex]
            let a = max(0, min(routePoints.count - 1, i0))
            let b = max(0, min(routePoints.count - 1, i1))

            let segmentPoints: [CGPoint] = {
                guard routePoints.count >= 2 else { return [startPoint, startPoint] }
                if a <= b {
                    return Array(routePoints[a...b])
                } else {
                    // If indices go backwards, still animate smoothly backwards.
                    return Array(routePoints[b...a].reversed())
                }
            }()

            let legFrames = frames(settings.walkSecondsPerLeg)
            for f in 0..<legFrames {
                let tt = CGFloat(f) / CGFloat(max(1, legFrames - 1))
                let sample = sampleAlongPolyline(points: segmentPoints, t: tt)
                let stepPhase = CGFloat(f) / CGFloat(max(1, settings.fps)) * 2.0 // ~2 steps/sec
                try await drawMapWithDot(dotPoint: sample.point, heading: sample.heading, stepPhase: stepPhase, label: nil)
            }

            // At each real stop (after walking into it), play zoom → look around → photo → zoom out.
            if legIndex < stops.count {
                let stop = stops[legIndex]
                let stopPt = stopPoints[legIndex]

                // Zoom in.
                let zoomFrames = frames(settings.zoomSeconds)
                for f in 0..<zoomFrames {
                    let t = CGFloat(f) / CGFloat(max(1, zoomFrames - 1))
                    let scale = 1.0 + 0.9 * t
                    try await drawMapWithDot(dotPoint: stopPt, zoomScale: scale, zoomCenter: stopPt, label: stop.title)
                }

                // Look Around hold (fallback to a tighter map crop if unavailable).
                let la = lookAroundImages[legIndex]
                let lookHoldFrames = frames(settings.lookAroundHold)
                if let la {
                    for _ in 0..<lookHoldFrames {
                        try await appendFrame { ctx in
                            drawUIImage(la, in: ctx)
                            drawOverlayLabel(stop.title, in: ctx)
                        }
                    }
                } else {
                    // Map fallback (zoomed-in).
                    for _ in 0..<lookHoldFrames {
                        try await drawMapWithDot(dotPoint: stopPt, zoomScale: 1.9, zoomCenter: stopPt, label: stop.title)
                    }
                }

                // Crossfade Look Around (or map fallback) -> photo.
                let cfFrames = frames(settings.crossfadeSeconds)
                for f in 0..<cfFrames {
                    let t = CGFloat(f) / CGFloat(max(1, cfFrames - 1))
                    try await appendFrame { ctx in
                        if let la {
                            drawUIImage(la, alpha: 1.0 - t, in: ctx)
                        } else {
                            // Use zoomed map as source.
                            let center = stopPt
                            let tr = CGAffineTransform(translationX: center.x, y: center.y)
                                .scaledBy(x: 1.9, y: 1.9)
                                .translatedBy(x: -center.x, y: -center.y)
                            drawUIImage(baseMap, alpha: 1.0 - t, transform: tr, in: ctx)
                        }
                        drawKenBurns(stop.image, t: t, in: ctx)
                        drawOverlayLabel(stop.title, in: ctx)
                    }
                }

                // Photo hold (Ken Burns).
                let photoFrames = frames(settings.photoHold)
                for f in 0..<photoFrames {
                    let t = CGFloat(f) / CGFloat(max(1, photoFrames - 1))
                    try await appendFrame { ctx in
                        drawKenBurns(stop.image, t: t, in: ctx)
                        drawOverlayLabel(stop.title, in: ctx)
                    }
                }

                // Zoom out back to full map.
                let outFrames = frames(settings.zoomOutSeconds)
                for f in 0..<outFrames {
                    let t = CGFloat(f) / CGFloat(max(1, outFrames - 1))
                    let scale = 1.9 - 0.9 * t
                    try await drawMapWithDot(dotPoint: stopPt, zoomScale: scale, zoomCenter: stopPt, label: nil)
                }
            }
        }

        // END hold.
        let endPoint = routePoints.last ?? startPoint
        for _ in 0..<frames(settings.endHold) {
            try await drawMapWithDot(dotPoint: endPoint, label: "Done")
        }

        input.markAsFinished()
        await withCheckedContinuation { cont in
            writer.finishWriting { cont.resume() }
        }

        return outputURL
    }

    // MARK: - Map Snapshot

    private struct MapSnapshot {
        let image: UIImage
        let point: (CLLocationCoordinate2D) -> CGPoint

        func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
            point(coordinate)
        }
    }

    private func makeRouteMapSnapshot(
        routeCoordinates: [CLLocationCoordinate2D],
        stops: [PhotoStop],
        settings: Settings
    ) async throws -> MapSnapshot {
        let opts = MKMapSnapshotter.Options()
        opts.size = settings.size
        opts.scale = 1.0
        // Use standard Apple Maps styling and force DARK mode so the snapshot matches Apple Maps Dark Mode.
        // (Do NOT apply any custom tint/filters; let MapKit render the palette.)
        opts.mapType = .standard
        if #available(iOS 13.0, *) {
            opts.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        }
        opts.showsBuildings = true
        opts.showsPointsOfInterest = false

        // Fit the snapshot to route + stops.
        let all = routeCoordinates + stops.map { $0.coordinate }
        let rect = all
            .map { MKMapPoint($0) }
            .reduce(MKMapRect.null) { $0.union(MKMapRect(origin: $1, size: MKMapSize(width: 0, height: 0))) }

        var padded = rect
        if !padded.isNull {
            let pad = max(padded.size.width, padded.size.height) * 0.22
            padded = padded.insetBy(dx: -pad, dy: -pad)
        }
        opts.mapRect = padded

        let snapshotter = MKMapSnapshotter(options: opts)

        return try await withCheckedThrowingContinuation { cont in
            snapshotter.start(with: .main) { snap, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let snap else {
                    cont.resume(throwing: GenerationError.failedToMakeMapSnapshot)
                    return
                }

                // Draw route + markers onto snapshot.
                let rendered = UIGraphicsImageRenderer(size: settings.size, format: {
                    let f = UIGraphicsImageRendererFormat()
                    f.scale = 1.0
                    f.opaque = true
                    if #available(iOS 12.0, *) {
                        f.preferredRange = .standard
                    }
                    return f
                }()).image { ctx in
                    snap.image.draw(in: CGRect(origin: .zero, size: settings.size))

                    // Route polyline.
                    if routeCoordinates.count >= 2 {
                        let path = UIBezierPath()
                        for (i, c) in routeCoordinates.enumerated() {
                            let p = snap.point(for: c)
                            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                        }
                        path.lineWidth = settings.routeLineWidth
                        path.lineJoinStyle = .round
                        path.lineCapStyle = .round
                        settings.routeStrokeColor.setStroke()
                        path.stroke()
                    }

                    // Numbered markers.
                    for (idx, stop) in stops.enumerated() {
                        let p = snap.point(for: stop.coordinate)
                        let r: CGFloat = 18
                        let rect = CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)
                        UIColor.white.setFill()
                        UIBezierPath(ovalIn: rect).fill()
                        UIColor.black.withAlphaComponent(0.25).setStroke()
                        UIBezierPath(ovalIn: rect.insetBy(dx: -1, dy: -1)).stroke()

                        let num = "\(idx + 1)" as NSString
                        let attrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                            .foregroundColor: UIColor.black
                        ]
                        let s = num.size(withAttributes: attrs)
                        num.draw(at: CGPoint(x: p.x - s.width / 2, y: p.y - s.height / 2), withAttributes: attrs)
                    }
                }

                cont.resume(returning: MapSnapshot(
                    image: rendered,
                    point: { coordinate in snap.point(for: coordinate) }
                ))
            }
        }
    }

    // MARK: - Look Around

    @available(iOS 16.0, *)
    private static func fetchLookAroundImage(at coordinate: CLLocationCoordinate2D, size: CGSize) async -> UIImage? {
        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            let scene = try await request.scene
            guard let scene else { return nil }

            let options = MKLookAroundSnapshotter.Options()
            options.size = size
            options.pointOfInterestFilter = .excludingAll

            let snapshotter = MKLookAroundSnapshotter(scene: scene, options: options)
            let snap = try await snapshotter.snapshot
            return snap.image
        } catch {
            return nil
        }
    }

    // MARK: - Export

    /// Save a generated video file to the user's Photo Library.
    func saveVideoToPhotosLibrary(fileURL: URL) async throws {
        // Ensure permission.
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .notDetermined {
            _ = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        }

        let final = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        guard final == .authorized || final == .limited else {
            throw NSError(domain: "MuterVideoGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photos access not granted."])
        }

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, any Error>) in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: fileURL, options: nil)
            } completionHandler: { success, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                if success {
                    cont.resume(returning: ())
                } else {
                    cont.resume(throwing: NSError(domain: "MuterVideoGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to save video."]))
                }
            }
        }
    }
}

