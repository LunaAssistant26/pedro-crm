import Foundation
import UIKit
import MapKit
import CoreLocation

/// Utility class for generating map snapshots for sharing
@MainActor
class RouteSnapshotGenerator {
    static let shared = RouteSnapshotGenerator()
    
    private init() {}
    
    /// Generate a snapshot of the route map
    func generateSnapshot(
        route: Route,
        size: CGSize = CGSize(width: 800, height: 800),
        completion: @escaping (UIImage?) -> Void
    ) {
        let options = MKMapSnapshotter.Options()
        options.size = size
        options.mapType = .standard
        options.showsBuildings = true
        
        // Calculate region that fits all route coordinates
        let coordinates = route.pathCoordinates
        guard !coordinates.isEmpty else {
            completion(nil)
            return
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

        // Expand the bounding rect a bit so the route isn't clipped at the edges.
        var rect = polyline.boundingMapRect
        let expandFactor: Double = 1.35
        rect = MKMapRect(
            x: rect.origin.x - rect.size.width * (expandFactor - 1) / 2,
            y: rect.origin.y - rect.size.height * (expandFactor - 1) / 2,
            width: rect.size.width * expandFactor,
            height: rect.size.height * expandFactor
        )

        options.region = MKCoordinateRegion(rect)
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(error?.localizedDescription ?? "unknown")")
                completion(nil)
                return
            }
            
            // Draw the route on the snapshot
            let image = UIGraphicsImageRenderer(size: size).image { context in
                // Draw the map snapshot
                snapshot.image.draw(at: .zero)
                
                // Get the context
                let cgContext = context.cgContext
                
                // Draw the route line
                let path = UIBezierPath()
                var firstPoint = true
                
                for coordinate in coordinates {
                    let point = snapshot.point(for: coordinate)
                    if firstPoint {
                        path.move(to: point)
                        firstPoint = false
                    } else {
                        path.addLine(to: point)
                    }
                }
                
                // Style the path
                cgContext.saveGState()
                cgContext.setLineWidth(6)
                cgContext.setStrokeColor(route.routeColor.uiColor.cgColor)
                cgContext.setLineCap(.round)
                cgContext.setLineJoin(.round)
                cgContext.addPath(path.cgPath)
                cgContext.strokePath()
                cgContext.restoreGState()
                
                // Draw start and end markers
                if let startCoordinate = coordinates.first {
                    self.drawMarker(at: snapshot.point(for: startCoordinate), color: .green, label: "S", in: cgContext)
                }
                
                if let endCoordinate = coordinates.last, coordinates.count > 1 {
                    self.drawMarker(at: snapshot.point(for: endCoordinate), color: .red, label: "E", in: cgContext)
                }
                
                // Draw landmark pins
                for (index, landmark) in route.landmarks.enumerated() {
                    let point = snapshot.point(for: landmark.location.clLocation)
                    self.drawPin(at: point, color: route.routeColor.uiColor, number: index + 1, in: cgContext)
                }
            }
            
            completion(image)
        }
    }
    
    /// Generate a snapshot async
    func generateSnapshot(route: Route, size: CGSize = CGSize(width: 800, height: 800)) async -> UIImage? {
        await withCheckedContinuation { continuation in
            generateSnapshot(route: route, size: size) { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func drawMarker(at point: CGPoint, color: UIColor, label: String, in context: CGContext) {
        let radius: CGFloat = 15
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        
        context.saveGState()
        
        // Draw circle
        color.setFill()
        context.fillEllipse(in: rect)
        
        // Draw border
        UIColor.white.setStroke()
        context.setLineWidth(3)
        context.strokeEllipse(in: rect)
        
        // Draw label
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let string = NSAttributedString(string: label, attributes: attributes)
        let size = string.size()
        string.draw(at: CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2))
        
        context.restoreGState()
    }
    
    private func drawPin(at point: CGPoint, color: UIColor, number: Int, in context: CGContext) {
        let radius: CGFloat = 18
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        
        context.saveGState()
        
        // Draw circle
        color.setFill()
        context.fillEllipse(in: rect)
        
        // Draw white border
        UIColor.white.setStroke()
        context.setLineWidth(3)
        context.strokeEllipse(in: rect)
        
        // Draw number
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let string = NSAttributedString(string: "\(number)", attributes: attributes)
        let size = string.size()
        string.draw(at: CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2))
        
        context.restoreGState()
    }
}

// MARK: - MKCoordinateRegion Extension

private extension MKCoordinateRegion {
    init(_ rect: MKMapRect) {
        let center = MKMapPoint(x: rect.midX, y: rect.midY)
        let span = MKCoordinateSpan(
            latitudeDelta: rect.height / 111000,
            longitudeDelta: rect.width / 111000
        )
        self.init(center: center.coordinate, span: span)
    }
}
