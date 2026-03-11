import SwiftUI

/// Post-walk actions shown when the user finishes navigation.
/// MVP: show route stats (estimated), photo count, and CTAs for collage + sharing.
struct FinishWalkActionsSheetView: View {
    let route: Route
    let photoCount: Int

    var onCreateCollage: () -> Void
    var onCreateMuterVideo: () -> Void
    var onShareRoute: () -> Void
    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard

                VStack(alignment: .leading, spacing: 10) {
                    Text("Next")
                        .font(.headline)

                    Button {
                        onCreateCollage()
                    } label: {
                        Label("Create Collage", systemImage: "photo.on.rectangle.angled")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(photoCount == 0)

                    Button {
                        onCreateMuterVideo()
                    } label: {
                        Label("Create Muter Video", systemImage: "sparkles.rectangle.stack")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .disabled(photoCount == 0)

                    Button {
                        onShareRoute()
                    } label: {
                        Label("Share Route", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)

                    Button {
                        onDone()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Walk Finished")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { onDone() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(route.name)
                .font(.title3.weight(.bold))

            HStack(spacing: 12) {
                Label("\(route.duration)m", systemImage: "clock")
                Label(String(format: "%.1f km", route.distance), systemImage: "figure.walk")
                Label("\(photoCount)", systemImage: "camera")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)

            if photoCount == 0 {
                Text("No photos captured on this walk. You can still share the route.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
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
        coordinates: [],
        navigationSteps: nil,
        imageURL: nil,
        city: "Amsterdam"
    )

    return FinishWalkActionsSheetView(
        route: route,
        photoCount: 3,
        onCreateCollage: {},
        onCreateMuterVideo: {},
        onShareRoute: {},
        onDone: {}
    )
}
