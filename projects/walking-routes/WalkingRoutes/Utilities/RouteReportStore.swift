import Foundation
import CoreLocation

/// Stores user-reported "bad" routes and the geographic areas to avoid when generating new ones.
/// Routes through gated/private areas or unsafe paths are flagged here so they're
/// filtered out and their waypoint areas are avoided on the next generation.
enum RouteReportStore {

    enum ReportReason: String, Codable, CaseIterable {
        case privateOrGated  = "Private / Gated area"
        case unsafePath      = "Unsafe path"
        case wrongDirection  = "Wrong direction (one-way)"
        case other           = "Other issue"
    }

    struct Report: Codable {
        let routeID: UUID
        let reason: ReportReason
        let centerLatitude: Double
        let centerLongitude: Double
        let radiusMeters: Double
        let reportedAt: Date
    }

    private static let key = "reportedRoutes"

    // MARK: - Read

    static func allReports() -> [Report] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let reports = try? JSONDecoder().decode([Report].self, from: data) else { return [] }
        return reports
    }

    static func isReported(_ routeID: UUID) -> Bool {
        allReports().contains { $0.routeID == routeID }
    }

    /// Returns center coordinates of all reported areas within `searchRadius` metres of `coordinate`.
    /// Used by route generation to avoid placing waypoints near known bad areas.
    static func reportedAreas(near coordinate: CLLocationCoordinate2D,
                              searchRadius: CLLocationDistance = 5_000) -> [CLLocationCoordinate2D] {
        let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return allReports().compactMap { report -> CLLocationCoordinate2D? in
            let center = CLLocation(latitude: report.centerLatitude, longitude: report.centerLongitude)
            guard here.distance(from: center) <= searchRadius else { return nil }
            return CLLocationCoordinate2D(latitude: report.centerLatitude, longitude: report.centerLongitude)
        }
    }

    // MARK: - Write

    static func report(routeID: UUID, reason: ReportReason, routeCenter: CLLocationCoordinate2D, routeRadius: Double) {
        var reports = allReports()
        // Don't duplicate
        guard !reports.contains(where: { $0.routeID == routeID }) else { return }
        let report = Report(
            routeID: routeID,
            reason: reason,
            centerLatitude: routeCenter.latitude,
            centerLongitude: routeCenter.longitude,
            radiusMeters: routeRadius,
            reportedAt: Date()
        )
        reports.append(report)
        if let data = try? JSONEncoder().encode(reports) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
