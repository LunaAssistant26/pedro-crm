import SwiftUI
import MapKit
import CoreLocation

// MARK: - Model

struct SearchedLocation: Equatable {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let subtitle: String

    static func == (lhs: SearchedLocation, rhs: SearchedLocation) -> Bool {
        lhs.name == rhs.name && lhs.subtitle == rhs.subtitle
    }
}

// MARK: - View

struct LocationSearchView: View {
    @Binding var selectedLocation: SearchedLocation?
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    @StateObject private var searcher = LocalSearcher()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Hotel, address, neighbourhood…", text: $query)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                        .onSubmit { performSearch() }
                    if !query.isEmpty {
                        Button { query = ""; results = [] } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 8)

                if isSearching {
                    ProgressView().padding(.top, 20)
                    Spacer()
                } else if results.isEmpty && !query.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "mappin.slash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No results found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    Spacer()
                } else {
                    List(results, id: \.self) { item in
                        Button {
                            select(item)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.name ?? "Unknown")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                if let addr = item.placemark.formattedAddress, !addr.isEmpty {
                                    Text(addr)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: query) { newValue in
            searcher.debounceSearch(query: newValue) { items in
                results = items
                isSearching = false
            }
            if newValue.isEmpty { results = [] }
            else { isSearching = true }
        }
    }

    private func performSearch() {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        searcher.search(query: query) { items in
            results = items
            isSearching = false
        }
    }

    private func select(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        let name  = item.name ?? item.placemark.formattedAddress ?? "Selected location"
        let sub   = item.placemark.formattedAddress ?? ""
        selectedLocation = SearchedLocation(coordinate: coord, name: name, subtitle: sub)
        dismiss()
    }
}

// MARK: - Searcher (debounced MKLocalSearch)

@MainActor
final class LocalSearcher: ObservableObject {
    private var debounceTask: Task<Void, Never>?
    private var activeSearch: MKLocalSearch?

    func debounceSearch(query: String, completion: @escaping ([MKMapItem]) -> Void) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000) // 400ms debounce
            guard !Task.isCancelled else { return }
            search(query: query, completion: completion)
        }
    }

    func search(query: String, completion: @escaping ([MKMapItem]) -> Void) {
        activeSearch?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { completion([]); return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = [.address, .pointOfInterest]

        let search = MKLocalSearch(request: request)
        activeSearch = search
        search.start { response, _ in
            DispatchQueue.main.async {
                completion(response?.mapItems ?? [])
            }
        }
    }
}

// MARK: - Placemark helper

private extension MKPlacemark {
    var formattedAddress: String? {
        let parts = [subThoroughfare, thoroughfare, locality, administrativeArea, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}
