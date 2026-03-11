import Foundation
import UIKit
import AVFoundation

/// Service for generating photo collages
@MainActor
class CollageGenerator {
    static let shared = CollageGenerator()
    
    private init() {}
    
    /// Generate a collage from photos and optional map snapshot
    func generateCollage(
        photos: [UIImage],
        mapSnapshot: UIImage? = nil,
        route: Route,
        template: CollageTemplate,
        size: CGSize = CGSize(width: 1200, height: 1200)
    ) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            switch template {
            case .grid2x2:
                drawGrid2x2(photos: photos, route: route, size: size, in: context)
            case .grid3x3:
                drawGrid3x3(photos: photos, route: route, size: size, in: context)
            case .filmStrip:
                drawFilmStrip(photos: photos, route: route, size: size, in: context)
            case .story:
                drawStory(photos: photos, mapSnapshot: mapSnapshot, route: route, size: size, in: context)
            case .polaroid:
                drawPolaroid(photos: photos, route: route, size: size, in: context)
            }
        }
    }
    
    // MARK: - Template Drawing Methods
    
    private func drawGrid2x2(photos: [UIImage], route: Route, size: CGSize, in context: UIGraphicsImageRendererContext) {
        let padding: CGFloat = 20
        let cellSize = (size.width - padding * 3) / 2
        
        // Background
        route.routeColor.uiColor.withAlphaComponent(0.1).setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw photos in 2x2 grid
        for (index, photo) in photos.prefix(4).enumerated() {
            let row = CGFloat(index / 2)
            let col = CGFloat(index % 2)
            let x = padding + col * (cellSize + padding)
            let y = padding + row * (cellSize + padding)
            
            let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
            
            // Clip to rounded rect
            context.cgContext.saveGState()
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 16)
            path.addClip()
            photo.draw(in: rect)
            context.cgContext.restoreGState()
            
            // Border
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(4)
            context.cgContext.stroke(rect)
        }
        
        // Fill empty slots with placeholders if needed
        let placeholderCount = max(0, 4 - photos.count)
        for index in 0..<placeholderCount {
            let actualIndex = photos.count + index
            let row = CGFloat(actualIndex / 2)
            let col = CGFloat(actualIndex % 2)
            let x = padding + col * (cellSize + padding)
            let y = padding + row * (cellSize + padding)
            
            let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
            
            // Draw placeholder
            UIColor.systemGray5.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 16).fill()
            
            // Draw icon
            let iconAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 60),
                .foregroundColor: UIColor.systemGray3
            ]
            let iconString = NSAttributedString(string: "📷", attributes: iconAttributes)
            let iconSize = iconString.size()
            iconString.draw(at: CGPoint(
                x: rect.midX - iconSize.width / 2,
                y: rect.midY - iconSize.height / 2
            ))
        }
        
        // Route info at bottom
        drawRouteInfo(route: route, at: CGPoint(x: 0, y: size.height - 100), width: size.width, in: context)
    }
    
    private func drawGrid3x3(photos: [UIImage], route: Route, size: CGSize, in context: UIGraphicsImageRendererContext) {
        let padding: CGFloat = 12
        let cellSize = (size.width - padding * 4) / 3
        
        // Background
        UIColor.black.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw photos in 3x3 grid
        for (index, photo) in photos.prefix(9).enumerated() {
            let row = CGFloat(index / 3)
            let col = CGFloat(index % 3)
            let x = padding + col * (cellSize + padding)
            let y = padding + row * (cellSize + padding)
            
            let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
            
            context.cgContext.saveGState()
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
            path.addClip()
            photo.draw(in: rect)
            context.cgContext.restoreGState()
        }
    }
    
    private func drawFilmStrip(photos: [UIImage], route: Route, size: CGSize, in context: UIGraphicsImageRendererContext) {
        let filmHeight = size.height * 0.7
        let padding: CGFloat = 20
        let photoHeight = filmHeight - padding * 2
        let photoWidth = photoHeight * 1.5
        
        // Background
        UIColor.black.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Film strip background
        let filmRect = CGRect(x: 0, y: (size.height - filmHeight) / 2, width: size.width, height: filmHeight)
        UIColor(white: 0.1, alpha: 1).setFill()
        context.fill(filmRect)
        
        // Draw perforations
        let perfSize: CGFloat = 12
        let perfSpacing: CGFloat = 20
        var x: CGFloat = perfSpacing
        while x < size.width {
            // Top perforations
            let topPerf = CGRect(x: x, y: filmRect.minY + 10, width: perfSize, height: perfSize)
            UIColor(white: 0.3, alpha: 1).setFill()
            context.fill(topPerf)
            
            // Bottom perforations
            let bottomPerf = CGRect(x: x, y: filmRect.maxY - 22, width: perfSize, height: perfSize)
            context.fill(bottomPerf)
            
            x += perfSize + perfSpacing
        }
        
        // Draw photos
        let startX = (size.width - (CGFloat(min(photos.count, 4)) * (photoWidth + padding) - padding)) / 2
        for (index, photo) in photos.prefix(4).enumerated() {
            let photoX = startX + CGFloat(index) * (photoWidth + padding)
            let photoY = filmRect.minY + (filmHeight - photoHeight) / 2
            let rect = CGRect(x: photoX, y: photoY, width: photoWidth, height: photoHeight)
            
            photo.draw(in: rect)
            
            // White border
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(2)
            context.cgContext.stroke(rect.insetBy(dx: -2, dy: -2))
        }
        
        // Route info
        drawRouteInfo(route: route, at: CGPoint(x: 0, y: size.height - 80), width: size.width, in: context)
    }
    
    private func drawStory(photos: [UIImage], mapSnapshot: UIImage?, route: Route, size: CGSize, in context: UIGraphicsImageRendererContext) {
        // Background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [
            route.routeColor.uiColor.cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.render(in: context.cgContext)
        
        // Map snapshot (if available)
        if let mapSnapshot = mapSnapshot {
            let mapSize = size.width * 0.9
            let mapRect = CGRect(
                x: (size.width - mapSize) / 2,
                y: 80,
                width: mapSize,
                height: mapSize
            )
            mapSnapshot.draw(in: mapRect)
            
            // Border
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(4)
            context.cgContext.stroke(mapRect.insetBy(dx: -2, dy: -2))
        }
        
        // Photo thumbnails at bottom
        let thumbSize: CGFloat = 180
        let thumbSpacing: CGFloat = 20
        let startX = (size.width - (CGFloat(min(photos.count, 4)) * (thumbSize + thumbSpacing) - thumbSpacing)) / 2
        
        for (index, photo) in photos.prefix(4).enumerated() {
            let x = startX + CGFloat(index) * (thumbSize + thumbSpacing)
            let thumbRect = CGRect(x: x, y: size.height - thumbSize - 200, width: thumbSize, height: thumbSize)
            
            context.cgContext.saveGState()
            let path = UIBezierPath(roundedRect: thumbRect, cornerRadius: 12)
            path.addClip()
            photo.draw(in: thumbRect)
            context.cgContext.restoreGState()
            
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.stroke(thumbRect)
        }
        
        // Route info
        drawRouteInfo(route: route, at: CGPoint(x: 0, y: size.height - 120), width: size.width, in: context, large: true)
    }
    
    private func drawPolaroid(photos: [UIImage], route: Route, size: CGSize, in context: UIGraphicsImageRendererContext) {
        let padding: CGFloat = 30
        let polaroidWidth = (size.width - padding * 3) / 2
        let polaroidHeight = polaroidWidth * 1.2
        let photoSize = polaroidWidth - 40
        
        // Background
        UIColor(white: 0.95, alpha: 1).setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw polaroid frames
        for (index, photo) in photos.prefix(4).enumerated() {
            let row = CGFloat(index / 2)
            let col = CGFloat(index % 2)
            let x = padding + col * (polaroidWidth + padding)
            let y = padding + row * (polaroidHeight + padding)
            
            let frameRect = CGRect(x: x, y: y, width: polaroidWidth, height: polaroidHeight)
            
            // White frame
            UIColor.white.setFill()
            UIBezierPath(roundedRect: frameRect, cornerRadius: 8).fill()
            
            // Shadow
            context.cgContext.saveGState()
            context.cgContext.setShadow(offset: CGSize(width: 0, height: 4), blur: 8, color: UIColor.black.withAlphaComponent(0.2).cgColor)
            context.cgContext.restoreGState()
            
            // Photo
            let photoRect = CGRect(
                x: frameRect.midX - photoSize / 2,
                y: frameRect.minY + 20,
                width: photoSize,
                height: photoSize
            )
            photo.draw(in: photoRect)
            
            // Caption area
            let captionY = photoRect.maxY + 20
            let captionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            let caption = NSAttributedString(string: "Walking Routes", attributes: captionAttributes)
            let captionSize = caption.size()
            caption.draw(at: CGPoint(x: frameRect.midX - captionSize.width / 2, y: captionY))
        }
    }
    
    // MARK: - Helper Methods
    
    private func drawRouteInfo(route: Route, at point: CGPoint, width: CGFloat, in context: UIGraphicsImageRendererContext, large: Bool = false) {
        let fontSize: CGFloat = large ? 48 : 32
        let subFontSize: CGFloat = large ? 24 : 18
        
        // Route name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let nameString = NSAttributedString(string: route.name, attributes: nameAttributes)
        let nameSize = nameString.size()
        nameString.draw(at: CGPoint(x: (width - nameSize.width) / 2, y: point.y + 10))
        
        // Stats
        let statsText = "\(String(format: "%.1f", route.distance)) km • \(route.duration) min • \(String(format: "%.1f", route.averageRating)) ⭐"
        let statsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: subFontSize, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        let statsString = NSAttributedString(string: statsText, attributes: statsAttributes)
        let statsSize = statsString.size()
        statsString.draw(at: CGPoint(x: (width - statsSize.width) / 2, y: point.y + 10 + nameSize.height + 8))
    }
}
