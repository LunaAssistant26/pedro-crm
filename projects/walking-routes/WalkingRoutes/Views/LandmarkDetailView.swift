import SwiftUI

struct LandmarkDetailView: View {
    let landmark: Landmark
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: landmark.imageURL ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            Rectangle().fill(Color.gray.opacity(0.25))
                        case .empty:
                            Rectangle().fill(Color.gray.opacity(0.2))
                        @unknown default:
                            Rectangle().fill(Color.gray.opacity(0.2))
                        }
                    }
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 10) {
                        Text(landmark.name)
                            .font(.title2.weight(.bold))

                        if let rating = landmark.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.subheadline.weight(.semibold))
                        }

                        HStack(spacing: 10) {
                            Label("\(landmark.estimatedTime) min", systemImage: "clock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text(landmark.description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider().padding(.vertical, 4)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tip")
                                .font(.headline)
                            Text("Look around, take photos, and consider visiting earlier in the day for fewer crowds.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Stop Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    LandmarkDetailView(
        landmark: Landmark(
            id: UUID(),
            name: "Anne Frank House",
            description: "The hiding place where Anne Frank wrote her famous diary during WWII.",
            location: Location(latitude: 52.3752, longitude: 4.8839),
            estimatedTime: 20,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Anne_Frank_House_Amsterdam.jpg/800px-Anne_Frank_House_Amsterdam.jpg",
            rating: 4.6
        )
    )
}
