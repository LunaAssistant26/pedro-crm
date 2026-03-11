import Foundation
import UIKit
import MapKit
import CoreLocation

/// Service for managing photo storage and retrieval
@MainActor
class PhotoService: ObservableObject {
    static let shared = PhotoService()
    
    @Published private(set) var allPhotos: [RoutePhoto] = []
    
    /// Directory where photos are stored
    let photosDirectory: URL
    
    private let userDefaults = UserDefaults.standard
    private let photosKey = "routePhotos"
    
    private init() {
        // Create photos directory in app's documents
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        photosDirectory = documentsDirectory.appendingPathComponent("RoutePhotos", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        
        // Load saved photos
        loadPhotos()
    }
    
    /// Save a photo for a specific route
    func savePhoto(
        image: UIImage,
        for routeId: UUID,
        at location: CLLocationCoordinate2D? = nil,
        note: String? = nil
    ) -> RoutePhoto? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let photoId = UUID()
        let filename = "\(photoId.uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            
            let photo = RoutePhoto(
                id: photoId,
                routeId: routeId,
                timestamp: Date(),
                latitude: location?.latitude ?? 0,
                longitude: location?.longitude ?? 0,
                filename: filename,
                note: note
            )
            
            allPhotos.append(photo)
            savePhotosMetadata()
            
            return photo
        } catch {
            print("Failed to save photo: \(error)")
            return nil
        }
    }
    
    /// Get all photos for a specific route
    func photos(for routeId: UUID) -> [RoutePhoto] {
        allPhotos.filter { $0.routeId == routeId }
    }
    
    /// Load an image for a photo
    func loadImage(for photo: RoutePhoto) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(photo.filename)
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: imageData)
    }
    
    /// Delete a photo
    func deletePhoto(_ photo: RoutePhoto) {
        let fileURL = photosDirectory.appendingPathComponent(photo.filename)
        try? FileManager.default.removeItem(at: fileURL)
        
        allPhotos.removeAll { $0.id == photo.id }
        savePhotosMetadata()
    }
    
    /// Delete all photos for a route
    func deletePhotos(for routeId: UUID) {
        let photosToDelete = photos(for: routeId)
        for photo in photosToDelete {
            deletePhoto(photo)
        }
    }

    /// Update the note/caption for a stored photo.
    func updateNote(photoId: UUID, note: String?) {
        guard let idx = allPhotos.firstIndex(where: { $0.id == photoId }) else { return }
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = (trimmed?.isEmpty == true) ? nil : trimmed

        let current = allPhotos[idx]
        allPhotos[idx] = RoutePhoto(
            id: current.id,
            routeId: current.routeId,
            timestamp: current.timestamp,
            latitude: current.latitude,
            longitude: current.longitude,
            filename: current.filename,
            note: normalized
        )
        savePhotosMetadata()
    }
    
    // MARK: - Private Methods
    
    private func loadPhotos() {
        guard let data = userDefaults.data(forKey: photosKey),
              let photos = try? JSONDecoder().decode([RoutePhoto].self, from: data) else {
            return
        }
        allPhotos = photos
    }
    
    private func savePhotosMetadata() {
        guard let data = try? JSONEncoder().encode(allPhotos) else { return }
        userDefaults.set(data, forKey: photosKey)
    }
}
