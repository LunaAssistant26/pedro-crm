import Foundation

/// Super lightweight persistence for whether a route has been completed.
/// MVP: store a set of completed route UUIDs in UserDefaults.
enum RouteCompletionStore {
    private static let completedRouteIDsKey = "completedRouteIDs"

    static func isCompleted(_ routeID: UUID) -> Bool {
        completedIDs().contains(routeID)
    }

    static func markCompleted(_ routeID: UUID) {
        var ids = completedIDs()
        ids.insert(routeID)
        save(ids)
    }

    static func markNotCompleted(_ routeID: UUID) {
        var ids = completedIDs()
        ids.remove(routeID)
        save(ids)
    }

    // MARK: - Private

    private static func completedIDs() -> Set<UUID> {
        guard let data = UserDefaults.standard.data(forKey: completedRouteIDsKey) else { return [] }
        if let arr = try? JSONDecoder().decode([UUID].self, from: data) {
            return Set(arr)
        }
        return []
    }

    private static func save(_ ids: Set<UUID>) {
        let arr = Array(ids)
        guard let data = try? JSONEncoder().encode(arr) else { return }
        UserDefaults.standard.set(data, forKey: completedRouteIDsKey)
    }
}
