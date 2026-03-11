import Foundation
import SwiftUI
import UIKit
import MapKit

/// Service for handling social sharing functionality
@MainActor
class ShareService: ObservableObject {
    static let shared = ShareService()
    
    private init() {}
    
    /// Generate a shareable image with route map and stats
    func generateShareImage(
        route: Route,
        mapSnapshot: UIImage? = nil,
        photos: [UIImage] = [],
        template: CollageTemplate = .grid2x2
    ) async -> UIImage? {
        // If we have a map snapshot and want a story format, create a story image
        if template == .story, let mapSnapshot = mapSnapshot {
            return await generateStoryImage(route: route, mapSnapshot: mapSnapshot, photos: photos)
        }
        
        // Otherwise generate a standard share card
        return await generateShareCard(route: route, mapSnapshot: mapSnapshot)
    }
    
    /// Generate a standard share card with route info
    private func generateShareCard(route: Route, mapSnapshot: UIImage?) async -> UIImage? {
        let size = CGSize(width: 1200, height: 630) // Social media friendly size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background
            let backgroundColor = route.routeColor.color
            backgroundColor.toUIColor().setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add gradient overlay
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.3).cgColor,
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.5).cgColor
            ]
            gradientLayer.locations = [0, 0.5, 1]
            gradientLayer.render(in: context.cgContext)
            
            // Map snapshot (if available)
            if let mapSnapshot = mapSnapshot {
                let mapRect = CGRect(x: 50, y: 50, width: 500, height: 530)
                mapSnapshot.draw(in: mapRect, blendMode: .normal, alpha: 0.9)
                
                // Map border
                context.cgContext.setStrokeColor(UIColor.white.cgColor)
                context.cgContext.setLineWidth(4)
                context.cgContext.stroke(mapRect.insetBy(dx: -2, dy: -2))
            }
            
            // Route name
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleString = NSAttributedString(string: route.name, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 600, y: 100))
            
            // Stats
            let statsY: CGFloat = 220
            let statSpacing: CGFloat = 140
            
            drawStat(
                icon: "figure.walk",
                value: String(format: "%.1f", route.distance),
                unit: "km",
                at: CGPoint(x: 600, y: statsY),
                in: context.cgContext
            )
            
            drawStat(
                icon: "clock",
                value: "\(route.duration)",
                unit: "min",
                at: CGPoint(x: 600 + statSpacing, y: statsY),
                in: context.cgContext
            )
            
            drawStat(
                icon: "star.fill",
                value: String(format: "%.1f", route.averageRating),
                unit: "rating",
                at: CGPoint(x: 600 + statSpacing * 2, y: statsY),
                in: context.cgContext
            )
            
            // Difficulty badge
            let difficultyColor: UIColor = {
                switch route.difficulty {
                case .easy: return .systemGreen
                case .moderate: return .systemOrange
                case .challenging: return .systemRed
                }
            }()
            
            let badgeRect = CGRect(x: 600, y: 380, width: 200, height: 60)
            difficultyColor.setFill()
            UIBezierPath(roundedRect: badgeRect, cornerRadius: 30).fill()
            
            let badgeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let badgeString = NSAttributedString(string: route.difficulty.rawValue, attributes: badgeAttributes)
            let badgeSize = badgeString.size()
            badgeString.draw(at: CGPoint(
                x: badgeRect.midX - badgeSize.width / 2,
                y: badgeRect.midY - badgeSize.height / 2
            ))
            
            // App branding
            let brandAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let brandString = NSAttributedString(string: "Walking Routes App", attributes: brandAttributes)
            brandString.draw(at: CGPoint(x: 600, y: 520))
        }
    }
    
    /// Generate an Instagram Story format image (9:16)
    private func generateStoryImage(route: Route, mapSnapshot: UIImage, photos: [UIImage]) async -> UIImage? {
        let size = CGSize(width: 1080, height: 1920) // Instagram Story dimensions
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background gradient
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.colors = [
                route.routeColor.uiColor.cgColor,
                UIColor.black.cgColor
            ]
            gradientLayer.render(in: context.cgContext)
            
            // Map snapshot (main feature)
            let mapRect = CGRect(x: 40, y: 200, width: 1000, height: 1000)
            mapSnapshot.draw(in: mapRect)
            
            // Map border with glow
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(6)
            context.cgContext.stroke(mapRect.insetBy(dx: -3, dy: -3))
            
            // Route name
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 64, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleString = NSAttributedString(string: route.name, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 60, y: 1250))
            
            // Stats row
            let statsY: CGFloat = 1380
            let statWidth: CGFloat = 300
            
            // Distance
            drawStoryStat(
                value: String(format: "%.1f", route.distance),
                label: "KILOMETERS",
                at: CGPoint(x: 60, y: statsY),
                width: statWidth,
                in: context.cgContext
            )
            
            // Duration
            drawStoryStat(
                value: "\(route.duration)",
                label: "MINUTES",
                at: CGPoint(x: 390, y: statsY),
                width: statWidth,
                in: context.cgContext
            )
            
            // Rating
            drawStoryStat(
                value: String(format: "%.1f", route.averageRating),
                label: "RATING",
                at: CGPoint(x: 720, y: statsY),
                width: statWidth,
                in: context.cgContext
            )
            
            // Photo thumbnails (if available)
            if !photos.isEmpty {
                let thumbSize: CGFloat = 180
                let thumbSpacing: CGFloat = 20
                let startX = (size.width - (CGFloat(min(photos.count, 4)) * (thumbSize + thumbSpacing) - thumbSpacing)) / 2
                
                for (index, photo) in photos.prefix(4).enumerated() {
                    let x = startX + CGFloat(index) * (thumbSize + thumbSpacing)
                    let thumbRect = CGRect(x: x, y: 1550, width: thumbSize, height: thumbSize)
                    
                    // Clip to rounded rect
                    context.cgContext.saveGState()
                    let path = UIBezierPath(roundedRect: thumbRect, cornerRadius: 16)
                    path.addClip()
                    photo.draw(in: thumbRect)
                    context.cgContext.restoreGState()
                    
                    // Border
                    context.cgContext.setStrokeColor(UIColor.white.cgColor)
                    context.cgContext.setLineWidth(3)
                    context.cgContext.stroke(thumbRect)
                }
            }
            
            // App branding at bottom
            let brandAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            let brandString = NSAttributedString(string: "Shared from Walking Routes", attributes: brandAttributes)
            let brandSize = brandString.size()
            brandString.draw(at: CGPoint(x: (size.width - brandSize.width) / 2, y: 1820))
        }
    }
    
    // MARK: - Helper Methods
    
    private func drawStat(icon: String, value: String, unit: String, at point: CGPoint, in context: CGContext) {
        // This is a simplified version - in production you'd use actual SF Symbols rendering
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let valueString = NSAttributedString(string: value, attributes: valueAttributes)
        valueString.draw(at: point)
        
        let unitAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        let unitString = NSAttributedString(string: unit, attributes: unitAttributes)
        unitString.draw(at: CGPoint(x: point.x, y: point.y + 55))
    }
    
    private func drawStoryStat(value: String, label: String, at point: CGPoint, width: CGFloat, in context: CGContext) {
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 56, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let valueString = NSAttributedString(string: value, attributes: valueAttributes)
        let valueSize = valueString.size()
        valueString.draw(at: CGPoint(x: point.x + (width - valueSize.width) / 2, y: point.y))
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        let labelString = NSAttributedString(string: label, attributes: labelAttributes)
        let labelSize = labelString.size()
        labelString.draw(at: CGPoint(x: point.x + (width - labelSize.width) / 2, y: point.y + 70))
    }
    
    /// Create a deep link URL for a route
    func createDeepLink(for route: Route) -> URL? {
        var components = URLComponents()
        components.scheme = "walkingroutes"
        components.host = "route"
        components.path = "/\(route.id.uuidString)"
        
        components.queryItems = [
            URLQueryItem(name: "name", value: route.name),
            URLQueryItem(name: "distance", value: String(route.distance)),
            URLQueryItem(name: "duration", value: String(route.duration))
        ]
        
        return components.url
    }
}

// MARK: - Color Extension

private extension Color {
    func toUIColor() -> UIColor {
        switch self {
        case .blue: return .systemBlue
        case .green: return .systemGreen
        case .orange: return .systemOrange
        case .purple: return .systemPurple
        case .teal: return .systemTeal
        case .indigo: return .systemIndigo
        case .red: return .systemRed
        case .yellow: return .systemYellow
        case .pink: return .systemPink
        case .cyan: return .systemCyan
        case .brown: return .systemBrown
        case .mint: return .systemMint
        default: return .systemGray
        }
    }
}
