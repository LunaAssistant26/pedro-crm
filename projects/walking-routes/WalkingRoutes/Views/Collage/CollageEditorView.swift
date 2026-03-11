import SwiftUI
import Photos
import UIKit

/// Create a collage from the photos captured during the route (optionally including the map snapshot).
struct CollageEditorView: View {
    let route: Route

    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoService = PhotoService.shared

    @State private var template: CollageTemplate = .grid2x2
    @State private var selectedPhotoIDs: Set<UUID> = []

    @State private var isGenerating = false
    @State private var collageImage: UIImage?

    @State private var showSystemShare = false
    @State private var shareItems: [Any] = []

    @State private var saveResultMessage: String?

    // Video generation
    @State private var isCreatingVideo = false
    @State private var videoProgress: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    templatePicker
                    preview
                    photoPicker
                    actions

                    if let saveResultMessage {
                        Text(saveResultMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Collage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Generate") {
                        Task { await generate() }
                    }
                    .disabled(isGenerating || selectedPhotos.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showSystemShare) {
            ActivityView(items: shareItems)
                .ignoresSafeArea()
        }
        .task {
            // Preselect up to 4 most recent photos
            if selectedPhotoIDs.isEmpty {
                let ids = photos.prefix(4).map(\.id)
                selectedPhotoIDs = Set(ids)
            }
            await generate()
        }
    }

    private var photos: [RoutePhoto] {
        photoService.photos(for: route.id).sorted { $0.timestamp > $1.timestamp }
    }

    private var selectedPhotos: [RoutePhoto] {
        photos.filter { selectedPhotoIDs.contains($0.id) }
    }

    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Template")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CollageTemplate.allCases) { t in
                        Button {
                            template = t
                            Task { await generate() }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: t.iconName)
                                    .font(.title3)
                                Text(t.displayName)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .frame(width: 120, height: 72)
                            .background(template == t ? AppTheme.primaryColor.opacity(0.18) : Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(template == t ? AppTheme.primaryColor : Color(.systemGray4), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))

                if isGenerating {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("Generating…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if isCreatingVideo {
                    VStack(spacing: 10) {
                        ProgressView(value: videoProgress)
                            .frame(maxWidth: 220)
                        Text(videoProgress > 0 ? "Creating video… \(Int(videoProgress * 100))%" : "Creating video…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if let image = collageImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Text("Select photos and generate")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 340)
        }
    }

    private var photoPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Photos")
                    .font(.headline)
                Spacer()
                Text("\(selectedPhotoIDs.count)/\(template.maxPhotos)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if photos.isEmpty {
                Text("No route photos found. Add photos during your walk first.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
                    ForEach(photos) { photo in
                        CollagePhotoPickTile(
                            photo: photo,
                            isSelected: selectedPhotoIDs.contains(photo.id)
                        ) {
                            toggle(photo: photo)
                        }
                    }
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                presentShare()
            } label: {
                Label("Share collage", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(collageImage == nil)

            Button {
                saveToPhotoLibrary()
            } label: {
                Label("Save to Photos", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(collageImage == nil)

            Button {
                Task { await createVideo() }
            } label: {
                Label("Create Video", systemImage: "film")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isCreatingVideo || selectedPhotos.isEmpty)
        }
    }

    // MARK: - Actions

    private func toggle(photo: RoutePhoto) {
        if selectedPhotoIDs.contains(photo.id) {
            selectedPhotoIDs.remove(photo.id)
        } else {
            guard selectedPhotoIDs.count < template.maxPhotos else { return }
            selectedPhotoIDs.insert(photo.id)
        }

        Task { await generate() }
    }

    @MainActor
    private func generate() async {
        saveResultMessage = nil
        isGenerating = true
        collageImage = nil

        let uiImages: [UIImage] = selectedPhotos
            .prefix(template.maxPhotos)
            .compactMap { PhotoService.shared.loadImage(for: $0) }

        guard !uiImages.isEmpty else {
            isGenerating = false
            return
        }

        let mapSnapshot: UIImage?
        if template.includesMap {
            mapSnapshot = await RouteSnapshotGenerator.shared.generateSnapshot(route: route, size: CGSize(width: 900, height: 900))
        } else {
            mapSnapshot = nil
        }

        // Size based on aspect ratio.
        let width: CGFloat = 1200
        let height: CGFloat = width / template.aspectRatio
        let targetSize = CGSize(width: width, height: max(800, height))

        collageImage = CollageGenerator.shared.generateCollage(
            photos: uiImages,
            mapSnapshot: mapSnapshot,
            route: route,
            template: template,
            size: targetSize
        )

        isGenerating = false
    }

    private func presentShare() {
        guard let image = collageImage else { return }
        var items: [Any] = [image]
        if let url = ShareService.shared.createDeepLink(for: route) {
            items.append(url)
        }
        shareItems = items
        showSystemShare = true
    }

    private func saveToPhotoLibrary() {
        guard let image = collageImage else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in
                    saveResultMessage = "Photo library permission denied."
                }
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Task { @MainActor in
                saveResultMessage = "Saved to Photos."
            }
        }
    }

    @MainActor
    private func createVideo() async {
        guard !selectedPhotos.isEmpty else { return }

        saveResultMessage = nil
        isCreatingVideo = true
        videoProgress = 0

        // Use chronological order for a nicer "journey" feel.
        let orderedPhotos = selectedPhotos.sorted { $0.timestamp < $1.timestamp }
        let images: [UIImage] = orderedPhotos.compactMap { PhotoService.shared.loadImage(for: $0) }

        guard !images.isEmpty else {
            isCreatingVideo = false
            saveResultMessage = "No images could be loaded."
            return
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        do {
            let url = try await RouteVideoGenerator.shared.generateMP4(
                images: images,
                overlays: { idx in
                    guard idx < orderedPhotos.count else { return nil }
                    let p = orderedPhotos[idx]
                    let time = timeFormatter.string(from: p.timestamp)
                    if p.latitude != 0 || p.longitude != 0 {
                        return String(format: "%@ • %.5f, %.5f", time, p.latitude, p.longitude)
                    }
                    return time
                },
                onProgress: { progress in
                    videoProgress = progress
                }
            )

            // Save to Photos so the user can share it anywhere.
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                isCreatingVideo = false
                saveResultMessage = "Photo library permission denied."
                return
            }

            try await saveVideoToPhotoLibrary(fileURL: url)
            saveResultMessage = "Video saved to Photos."
        } catch is CancellationError {
            saveResultMessage = "Video generation cancelled."
        } catch {
            saveResultMessage = "Failed to create video: \(error.localizedDescription)"
        }

        isCreatingVideo = false
    }

    private func saveVideoToPhotoLibrary(fileURL: URL) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            } completionHandler: { success, error in
                if let error {
                    cont.resume(throwing: error)
                } else if success {
                    cont.resume(returning: ())
                } else {
                    cont.resume(throwing: NSError(domain: "WalkingRoutes", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown Photos save error"]))
                }
            }
        }
    }
}

// MARK: - Tiles

private struct CollagePhotoPickTile: View {
    let photo: RoutePhoto
    let isSelected: Bool
    let onTap: () -> Void

    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
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

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.primaryColor : Color.white.opacity(0.85))
                    .padding(6)
            }
            .frame(width: 84, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .task {
            image = PhotoService.shared.loadImage(for: photo)
        }
    }
}

// MARK: - Share Sheet wrapper

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
