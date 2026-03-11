import SwiftUI
import UIKit
import LinkPresentation

/// SwiftUI share UI that generates a shareable image (map + stats) and presents the system share sheet.
///
/// Notes:
/// - Uses `UIActivityViewController` so it can target Instagram, WhatsApp, Telegram, X, Snapchat, TikTok (and more)
/// - Includes a deep link URL to open the route in the app
/// - Supports an Instagram Stories friendly 9:16 image
struct ShareSheetView: View {
    let route: Route

    @Environment(\.dismiss) private var dismiss

    @State private var shareFormat: ShareFormat = .standard
    @State private var isGenerating = true
    @State private var generatedImage: UIImage?
    @State private var showSystemShare = false
    @State private var shareItems: [Any] = []

    @State private var generationError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Format", selection: $shareFormat) {
                        ForEach(ShareFormat.allCases) { format in
                            Label(format.title, systemImage: format.systemImage)
                                .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)

                    previewSection

                    if let generationError {
                        Text(generationError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task(id: shareFormat) {
            await generate()
        }
        .sheet(isPresented: $showSystemShare) {
            ActivityView(items: shareItems)
                .ignoresSafeArea()
        }
    }

    // MARK: - UI

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                } else if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(8)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("Couldn’t generate preview")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                presentShareSheet()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(generatedImage == nil || isGenerating)

            HStack {
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy image", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .disabled(generatedImage == nil)

                Spacer()

                if let url = ShareService.shared.createDeepLink(for: route) {
                    ShareLink(item: url) {
                        Label("Share link", systemImage: "link")
                    }
                    .buttonStyle(.bordered)
                }
            }

            Text("Tip: Instagram Stories works best with the 9:16 format. You can also copy the image and paste into Instagram.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    @MainActor
    private func generate() async {
        generationError = nil
        isGenerating = true
        generatedImage = nil

        do {
            // 1) Map snapshot (if needed)
            let snapshotSize: CGSize = shareFormat == .story
                ? CGSize(width: 1000, height: 1000)
                : CGSize(width: 800, height: 800)

            let mapSnapshot = await RouteSnapshotGenerator.shared.generateSnapshot(route: route, size: snapshotSize)

            // 2) Load up to 4 photos for story thumbnails (optional)
            let routePhotos = PhotoService.shared.photos(for: route.id)
            let uiPhotos: [UIImage] = routePhotos
                .prefix(4)
                .compactMap { PhotoService.shared.loadImage(for: $0) }

            // 3) Render share image
            let template: CollageTemplate = (shareFormat == .story) ? .story : .grid2x2
            let image = await ShareService.shared.generateShareImage(route: route, mapSnapshot: mapSnapshot, photos: uiPhotos, template: template)

            generatedImage = image
            isGenerating = false

            if image == nil {
                generationError = "No image returned."
            }
        }
    }

    private func presentShareSheet() {
        guard let image = generatedImage else { return }

        var items: [Any] = []

        let deepLink = ShareService.shared.createDeepLink(for: route)

        // Use an item source so the share sheet can display a nicer preview.
        let itemSource = RouteShareItemSource(route: route, image: image, deepLink: deepLink)
        items.append(itemSource)

        if let url = deepLink {
            items.append(url)
        }

        shareItems = items
        showSystemShare = true
    }

    private func copyToClipboard() {
        guard let image = generatedImage else { return }
        UIPasteboard.general.image = image
    }
}

// MARK: - Share Format

private enum ShareFormat: String, CaseIterable, Identifiable {
    case standard
    case story

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Post"
        case .story: return "Story"
        }
    }

    var systemImage: String {
        switch self {
        case .standard: return "rectangle.portrait"
        case .story: return "iphone"
        }
    }
}

// MARK: - UIActivityViewController Wrapper

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // no-op
    }
}

// MARK: - Custom preview item

/// Provides the image + link with a better share sheet preview.
private final class RouteShareItemSource: NSObject, UIActivityItemSource {
    private let route: Route
    private let image: UIImage
    private let deepLink: URL?

    init(route: Route, image: UIImage, deepLink: URL?) {
        self.route = route
        self.image = image
        self.deepLink = deepLink
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        "Walking Route: \(route.name)"
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = route.name

        if let url = deepLink {
            metadata.originalURL = url
            metadata.url = url
        }

        if let png = image.pngData() {
            metadata.imageProvider = NSItemProvider(item: png as NSData, typeIdentifier: "public.png")
        }

        return metadata
    }
}
