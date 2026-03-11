import SwiftUI
import CoreLocation
import PhotosUI
import UIKit
import MapKit

/// Take / pick photos during a walk and store them per-route.
///
/// Storage is handled by `PhotoService` (Documents/RoutePhotos + JSON metadata in UserDefaults).
struct PhotoCaptureView: View {
    let routeId: UUID
    let currentLocation: CLLocationCoordinate2D?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoService = PhotoService.shared

    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var selectedPhoto: RoutePhoto?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if photos.isEmpty {
                        emptyState
                    } else {
                        photoGrid
                    }
                }
                .padding()
            }
            .navigationTitle("Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                        }

                        Button {
                            showLibrary = true
                        } label: {
                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                        }

                        if !photos.isEmpty {
                            Divider()

                            Button(role: .destructive) {
                                PhotoService.shared.deletePhotos(for: routeId)
                            } label: {
                                Label("Delete All", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                save(image: image)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibrary) {
            ImagePicker(sourceType: .photoLibrary) { image in
                save(image: image)
            }
            .ignoresSafeArea()
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
    }

    private var photos: [RoutePhoto] {
        photoService.photos(for: routeId).sorted { $0.timestamp > $1.timestamp }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Saved to this route")
                .font(.headline)

            Text("Photos are stored locally on your device.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("No photos yet")
                .font(.headline)

            Text("Take a photo during your walk and it will appear here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showLibrary = true
                } label: {
                    Label("Library", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var photoGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 12)], spacing: 12) {
            ForEach(photos) { photo in
                Button {
                    selectedPhoto = photo
                } label: {
                    PhotoThumbnail(photo: photo)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        PhotoService.shared.deletePhoto(photo)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func save(image: UIImage) {
        _ = PhotoService.shared.savePhoto(image: image, for: routeId, at: currentLocation)
    }
}

// MARK: - Thumbnail

private struct PhotoThumbnail: View {
    let photo: RoutePhoto
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                ProgressView()
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .task {
            // Simple async load; images are on-disk.
            image = PhotoService.shared.loadImage(for: photo)
        }
    }
}

// MARK: - Detail

private struct PhotoDetailView: View {
    let photo: RoutePhoto

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var note: String = ""
    @State private var showLocation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .frame(height: 260)
                            .overlay(ProgressView())
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(photo.timestamp, style: .date)
                                .font(.headline)
                            Text(photo.timestamp, style: .time)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            if photo.latitude != 0 || photo.longitude != 0 {
                                Text(String(format: "%.5f, %.5f", photo.latitude, photo.longitude))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if photo.latitude != 0 || photo.longitude != 0 {
                            Button {
                                showLocation = true
                            } label: {
                                Label("View Location", systemImage: "map")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.headline)

                        TextEditor(text: $note)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(role: .destructive) {
                        PhotoService.shared.deletePhoto(photo)
                        dismiss()
                    } label: {
                        Label("Delete Photo", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Notes are stored in metadata; keep it simple: delete+recreate would be bad.
                        // For now, we update the metadata list in-place.
                        updateNote(note)
                        dismiss()
                    }
                    .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines) == (photo.note ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            .task {
                image = PhotoService.shared.loadImage(for: photo)
                note = photo.note ?? ""
            }
        }
        .sheet(isPresented: $showLocation) {
            LookAroundTransitionView(
                coordinate: photo.location,
                photoImage: image,
                photoTimestamp: photo.timestamp
            )
        }
    }

    private func updateNote(_ newNote: String) {
        // PhotoService stores metadata in-memory + UserDefaults.
        // Update by replacing the element.
        let trimmed = newNote.trimmingCharacters(in: .whitespacesAndNewlines)
        PhotoService.shared.updateNote(photoId: photo.id, note: trimmed)
    }
}

// MARK: - UIImagePickerController bridge

private struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


// MARK: - Look Around Transition

/// A small "Map → Look Around → Photo" transition view.
///
/// Goal: delight the user by jumping from a photo to the real-world context (Look Around)
/// and then back to the user's captured photo.
///
/// Notes:
/// - Look Around is iOS 16+ but availability varies by location.
/// - When Look Around isn't available, we gracefully fall back to a map-only experience.
private struct LookAroundTransitionView: View {
    enum Stage {
        case map
        case lookAround
        case photo
    }

    let coordinate: CLLocationCoordinate2D
    let photoImage: UIImage?
    let photoTimestamp: Date?

    @Environment(\.dismiss) private var dismiss

    @State private var stage: Stage = .map
    @State private var scene: MKLookAroundScene?
    @State private var isLoadingScene = false

    @State private var mapRegion: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D, photoImage: UIImage?, photoTimestamp: Date?) {
        self.coordinate = coordinate
        self.photoImage = photoImage
        self.photoTimestamp = photoTimestamp
        _mapRegion = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                mapStage
                    .opacity(stage == .map ? 1 : 0)

                lookAroundStage
                    .opacity(stage == .lookAround ? 1 : 0)

                photoStage
                    .opacity(stage == .photo ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.55), value: stage)
            .navigationTitle("View Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Replay") {
                        Task { await playTransition() }
                    }
                }
            }
            .task {
                await loadSceneIfNeeded()
                await playTransition()
            }
        }
    }

    private var mapStage: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $mapRegion, annotationItems: [Pin(coordinate: coordinate)]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .red)
            }

            VStack(spacing: 8) {
                if isLoadingScene {
                    ProgressView("Loading Look Around…")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else if scene == nil {
                    Text("Look Around isn’t available here. Showing map instead.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Text("Map")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.bottom, 18)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var lookAroundStage: some View {
        ZStack(alignment: .bottom) {
            if let scene {
                LookAroundViewRepresentable(scene: scene)
                    .ignoresSafeArea(edges: .bottom)

                Text("Look Around")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 18)
            } else {
                Color.black
                    .overlay(Text("Look Around not available").foregroundStyle(.white))
            }
        }
    }

    private var photoStage: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea(edges: .bottom)

            if let photoImage {
                Image(uiImage: photoImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding()
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    Text("Photo unavailable")
                        .foregroundStyle(.secondary)
                }
            }

            if let photoTimestamp {
                Text(photoTimestamp, style: .time)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 18)
            }
        }
    }

    @MainActor
    private func loadSceneIfNeeded() async {
        guard scene == nil else { return }
        isLoadingScene = true

        let request = MKLookAroundSceneRequest(coordinate: coordinate)
        do {
            scene = try await request.scene
        } catch {
            // Not fatal: Look Around is optional.
            scene = nil
        }

        isLoadingScene = false
    }

    @MainActor
    private func playTransition() async {
        stage = .map
        try? await Task.sleep(nanoseconds: 650_000_000)

        if scene != nil {
            stage = .lookAround
            try? await Task.sleep(nanoseconds: 1_150_000_000)
        }

        stage = .photo
    }

    private struct Pin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}

/// UIKit bridge for `MKLookAroundViewController` (iOS 16+).
private struct LookAroundViewRepresentable: UIViewControllerRepresentable {
    let scene: MKLookAroundScene

    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        let vc = MKLookAroundViewController(scene: scene)
        vc.view.backgroundColor = .black
        return vc
    }

    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
        uiViewController.scene = scene
    }
}
