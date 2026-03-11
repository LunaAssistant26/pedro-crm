import SwiftUI
import os.log

// MARK: - Landmark Category

/// Categories for grouping and filtering landmarks
enum LandmarkCategory: String, CaseIterable, Identifiable {
    case museum = "museum"
    case art = "art"
    case history = "history"
    case park = "park"
    case outdoor = "outdoor"
    case dining = "dining"
    case cafe = "cafe"
    case shopping = "shopping"
    case architecture = "architecture"
    case entertainment = "entertainment"
    case other = "other"

    var id: String { rawValue }

    init?(from tag: String) {
        let normalized = tag.lowercased()
        for category in LandmarkCategory.allCases {
            if normalized == category.rawValue || normalized.contains(category.rawValue) {
                self = category
                return
            }
        }
        return nil
    }

    var displayName: String {
        switch self {
        case .museum: return "Museums"
        case .art: return "Art"
        case .history: return "History"
        case .park: return "Parks"
        case .outdoor: return "Outdoor"
        case .dining: return "Dining"
        case .cafe: return "Cafés"
        case .shopping: return "Shopping"
        case .architecture: return "Architecture"
        case .entertainment: return "Entertainment"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .museum: return "building.columns"
        case .art: return "paintbrush"
        case .history: return "book.closed"
        case .park: return "leaf"
        case .outdoor: return "sun.max"
        case .dining: return "fork.knife"
        case .cafe: return "cup.and.saucer"
        case .shopping: return "bag"
        case .architecture: return "building.2"
        case .entertainment: return "ticket"
        case .other: return "mappin"
        }
    }

    var color: Color {
        switch self {
        case .museum: return .indigo
        case .art: return .pink
        case .history: return .brown
        case .park: return .green
        case .outdoor: return .orange
        case .dining: return .red
        case .cafe: return .orange
        case .shopping: return .blue
        case .architecture: return .purple
        case .entertainment: return .teal
        case .other: return .gray
        }
    }
}

/// List view for landmarks with category filtering
struct LandmarkListView: View {
    let landmarks: [Landmark]
    var title: String = "Landmarks"
    var showGrouping: Bool = true

    @State private var selectedCategory: LandmarkCategory? = nil
    @State private var searchText: String = ""
    @State private var selectedLandmark: Landmark? = nil

    private let logger = Logger(subsystem: "com.walkingroutes", category: "LandmarkListView")

    // MARK: - Computed Properties

    private var categories: [LandmarkCategory] {
        let allTags = landmarks.flatMap { $0.tags }
        let uniqueTags = Set(allTags)
        return uniqueTags.compactMap { LandmarkCategory(from: $0) }
            .sorted { $0.displayName < $1.displayName }
    }

    private var filteredLandmarks: [Landmark] {
        var result = landmarks

        // Filter by category
        if let category = selectedCategory {
            result = result.filter { landmark in
                landmark.tags.contains(category.rawValue) ||
                landmark.tags.contains(where: { $0.lowercased() == category.rawValue.lowercased() })
            }
        }

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        return result
    }

    private var groupedLandmarks: [(LandmarkCategory, [Landmark])] {
        guard showGrouping && selectedCategory == nil && searchText.isEmpty else {
            return [(selectedCategory ?? .other, filteredLandmarks)]
        }

        let grouped = Dictionary(grouping: filteredLandmarks) { landmark in
            landmark.tags.first.flatMap { LandmarkCategory(from: $0) } ?? .other
        }

        return grouped
            .sorted { $0.key.displayName < $1.key.displayName }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)

                // Category filter
                if !categories.isEmpty {
                    categoryFilterSection
                        .padding(.horizontal)
                }

                // Results count
                HStack {
                    Text("\(filteredLandmarks.count) landmark\(filteredLandmarks.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if selectedCategory != nil || !searchText.isEmpty {
                        Button("Clear filters") {
                            selectedCategory = nil
                            searchText = ""
                        }
                        .font(.caption)
                    }
                }
                .padding(.horizontal)

                // Landmark list
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(groupedLandmarks, id: \.0) { category, landmarks in
                        VStack(alignment: .leading, spacing: 12) {
                            // Section header
                            if showGrouping {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundStyle(category.color)
                                    Text(category.displayName)
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                            }

                            // Cards
                            VStack(spacing: 10) {
                                ForEach(landmarks) { landmark in
                                    CompactLandmarkCard(landmark: landmark)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }

                if filteredLandmarks.isEmpty {
                    emptyStateView
                        .padding(.top, 40)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(title)
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
    }

    // MARK: - Sections

    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" button
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(categories) { category in
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No landmarks found")
                .font(.headline)

            Text("Try adjusting your filters or search terms")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Supporting Views

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search landmarks...", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? (color ?? AppTheme.primaryColor) : Color(.systemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LandmarkListView(
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Rijksmuseum",
                    description: "Dutch national museum dedicated to arts and history.",
                    location: Location(latitude: 52.3600, longitude: 4.8852),
                    estimatedTime: 45,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Rijksmuseum_Amsterdam.jpg/800px-Rijksmuseum_Amsterdam.jpg",
                    rating: 4.8,
                    tags: ["museum", "art"]
                ),
                Landmark(
                    id: UUID(),
                    name: "Anne Frank House",
                    description: "The hiding place where Anne Frank wrote her famous diary.",
                    location: Location(latitude: 52.3752, longitude: 4.8839),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Anne_Frank_House_Amsterdam.jpg/800px-Anne_Frank_House_Amsterdam.jpg",
                    rating: 4.6,
                    tags: ["museum", "history"]
                ),
                Landmark(
                    id: UUID(),
                    name: "Vondelpark",
                    description: "Amsterdam's most famous park.",
                    location: Location(latitude: 52.3584, longitude: 4.8699),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Vondelpark_Amsterdam.jpg/1200px-Vondelpark_Amsterdam.jpg",
                    rating: 4.6,
                    tags: ["park", "outdoor"]
                ),
                Landmark(
                    id: UUID(),
                    name: "Van Gogh Museum",
                    description: "Museum with the world's largest Van Gogh collection.",
                    location: Location(latitude: 52.3584, longitude: 4.8811),
                    estimatedTime: 60,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Van_Gogh_Museum_Amsterdam.jpg/800px-Van_Gogh_Museum_Amsterdam.jpg",
                    rating: 4.7,
                    tags: ["museum", "art"]
                )
            ],
            title: "Amsterdam Landmarks"
        )
    }
}
