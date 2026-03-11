import SwiftUI

struct RouteCard: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(route.description)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Text("\(route.duration)\nmin")
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                Text(String(format: "%.1f km", route.distance))
                Text("•")
                Text(route.difficulty.rawValue.capitalized)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    RouteCard(route: Route(
        id: UUID(),
        name: "Loop Option 1",
        description: "A 60-minute loop starting and ending where you are.",
        duration: 60,
        distance: 4.6,
        difficulty: .easy,
        category: .highlights,
        landmarks: [],
        coordinates: [],
        navigationSteps: nil,
        imageURL: nil,
        city: nil
    ))
    .padding()
}
