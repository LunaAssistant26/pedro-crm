import SwiftUI
import AVKit
import CoreLocation

/// Generates + previews the "Muter Video" and lets the user save it to Photos.
struct MuterVideoPreviewView: View {
    let route: Route

    @Environment(\.dismiss) private var dismiss
    @StateObject private var photoService = PhotoService.shared

    @State private var isGenerating = false
    @State private var progress: Double = 0
    @State private var videoURL: URL?
    @State private var errorText: String?
    @State private var didSaveToPhotos = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                if let videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 520)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal)
                } else {
                    placeholder
                }

                if isGenerating {
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                        Text("Generating… \(Int(progress * 100))%")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }

                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                VStack(spacing: 10) {
                    Button {
                        Task { await generate() }
                    } label: {
                        Label(videoURL == nil ? "Generate Muter Video" : "Regenerate", systemImage: "sparkles.rectangle.stack")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isGenerating || stops.isEmpty)

                    if let videoURL {
                        Button {
                            Task { await saveToPhotos(url: videoURL) }
                        } label: {
                            Label(didSaveToPhotos ? "Saved to Photos" : "Save to Photos", systemImage: didSaveToPhotos ? "checkmark.circle" : "square.and.arrow.down")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isGenerating)

                        ShareLink(item: videoURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isGenerating)
                    }

                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)

                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .navigationTitle("Muter Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                // Auto-generate the first time if we have stops.
                if videoURL == nil, !stops.isEmpty {
                    Task { await generate() }
                }
            }
        }
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemGray6))
                .frame(height: 520)
                .overlay {
                    VStack(spacing: 10) {
                        Image(systemName: "video")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(.secondary)

                        Text(stops.isEmpty ? "No photos found for this walk." : "Preparing your route video…")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

            if !stops.isEmpty {
                Text("Includes \(stops.count) photo stop(s) + Look Around (when available).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }

    private var stops: [MuterVideoGenerator.PhotoStop] {
        let photos = photoService.photos(for: route.id)
            .sorted { $0.timestamp < $1.timestamp }

        var out: [MuterVideoGenerator.PhotoStop] = []
        out.reserveCapacity(photos.count)

        for (idx, p) in photos.enumerated() {
            guard let image = photoService.loadImage(for: p) else { continue }

            let coord = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
            // Skip photos without a real location (older ones might be 0,0).
            if abs(coord.latitude) < 0.0001 && abs(coord.longitude) < 0.0001 { continue }

            let title: String
            if let note = p.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                title = note
            } else {
                title = "Stop \(idx + 1)"
            }

            out.append(.init(coordinate: coord, image: image, title: title))
        }

        // Cap to avoid overly long videos in MVP.
        return Array(out.prefix(6))
    }

    private func generate() async {
        guard !isGenerating else { return }
        errorText = nil
        didSaveToPhotos = false

        isGenerating = true
        progress = 0

        do {
            let url = try await MuterVideoGenerator.shared.generateMP4(
                routeCoordinates: route.pathCoordinates,
                stops: stops,
                settings: {
                    var s = MuterVideoGenerator.Settings()
                    s.routeStrokeColor = route.routeColor.uiColor
                    return s
                }(),
                onProgress: { p in
                    progress = p
                }
            )
            videoURL = url
        } catch {
            errorText = error.localizedDescription
        }

        isGenerating = false
    }

    private func saveToPhotos(url: URL) async {
        errorText = nil
        do {
            try await MuterVideoGenerator.shared.saveVideoToPhotosLibrary(fileURL: url)
            didSaveToPhotos = true
        } catch {
            errorText = error.localizedDescription
        }
    }
}

#Preview {
    let route = Route(
        id: UUID(),
        name: "Canal Ring Walk",
        description: "",
        duration: 55,
        distance: 4.8,
        difficulty: .easy,
        category: .highlights,
        landmarks: [],
        coordinates: [
            Location(latitude: 52.3780, longitude: 4.9006),
            Location(latitude: 52.3810, longitude: 4.9100),
            Location(latitude: 52.3720, longitude: 4.9150),
            Location(latitude: 52.3780, longitude: 4.9006)
        ],
        navigationSteps: nil,
        imageURL: nil,
        city: "Amsterdam"
    )

    return MuterVideoPreviewView(route: route)
}
