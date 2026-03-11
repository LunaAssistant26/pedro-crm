import Foundation
import UIKit

/// Defines different collage layout templates
enum CollageTemplate: String, CaseIterable, Identifiable {
    case grid2x2 = "2x2 Grid"
    case grid3x3 = "3x3 Grid"
    case filmStrip = "Film Strip"
    case story = "Story Format"
    case polaroid = "Polaroid"
    
    var id: String { rawValue }
    
    /// Display name for the template
    var displayName: String { rawValue }
    
    /// Icon name for the template
    var iconName: String {
        switch self {
        case .grid2x2: return "square.grid.2x2"
        case .grid3x3: return "square.grid.3x3"
        case .filmStrip: return "film"
        case .story: return "iphone"
        case .polaroid: return "photo.stack"
        }
    }
    
    /// Aspect ratio for the output image
    var aspectRatio: CGFloat {
        switch self {
        case .grid2x2, .grid3x3, .polaroid:
            return 1.0 // Square
        case .filmStrip:
            return 16.0 / 9.0 // Landscape
        case .story:
            return 9.0 / 16.0 // Portrait (Instagram Story)
        }
    }
    
    /// Number of photos this template can display
    var maxPhotos: Int {
        switch self {
        case .grid2x2: return 4
        case .grid3x3: return 9
        case .filmStrip: return 5
        case .story: return 4
        case .polaroid: return 4
        }
    }
    
    /// Whether this template includes the route map
    var includesMap: Bool {
        switch self {
        case .story: return true
        default: return false
        }
    }
}
