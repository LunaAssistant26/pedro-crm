import SwiftUI

enum CaptureScreen {
    case normal
    case home
    case loop
    case navigation
    case demo

    static func fromProcessArguments() -> CaptureScreen {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "--capture-screen"), args.indices.contains(flagIndex + 1) else {
            return .normal
        }

        switch args[flagIndex + 1].lowercased() {
        case "home": return .home
        case "loop": return .loop
        case "navigation": return .navigation
        case "demo": return .demo
        default: return .normal
        }
    }
}

private func makePreviewLoopRoute() -> Route {
    Route(
        id: UUID(),
        name: "Preview Loop",
        description: "A simple loop route used for capture/previews.",
        duration: 60,
        distance: 4.8,
        difficulty: .easy,
        category: .highlights,
        landmarks: Array(PointsOfInterest.all.prefix(2)),
        coordinates: [
            Location(latitude: 52.3780, longitude: 4.9006),
            Location(latitude: 52.3810, longitude: 4.9100),
            Location(latitude: 52.3720, longitude: 4.9150),
            Location(latitude: 52.3780, longitude: 4.9006)
        ],
        navigationSteps: nil,
        imageURL: nil,
        city: nil
    )
}

struct CaptureRootView: View {
    private let screen: CaptureScreen = .fromProcessArguments()

    var body: some View {
        let previewRoute = makePreviewLoopRoute()

        switch screen {
        case .home:
            ContentView(initialSelectedTime: 45, useLocation: false)
        case .loop:
            NavigationStack { RouteDetailView(route: previewRoute) }
        case .navigation:
            NavigationStack { RouteNavigationView(route: previewRoute, useLocation: false) }
        case .demo:
            DemoCaptureFlowView()
        case .normal:
            ContentView()
        }
    }
}

private struct DemoCaptureFlowView: View {
    @State private var stage: Int = 0

    var body: some View {
        let previewRoute = makePreviewLoopRoute()

        Group {
            switch stage {
            case 0:
                ContentView(initialSelectedTime: 30, useLocation: false)
            case 1:
                ContentView(initialSelectedTime: 60, useLocation: false)
            case 2:
                NavigationStack { RouteDetailView(route: previewRoute) }
            case 3:
                NavigationStack { RouteDetailView(route: previewRoute) }
            default:
                NavigationStack { RouteNavigationView(route: previewRoute, useLocation: false) }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { stage = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { stage = 2 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { stage = 3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) { stage = 4 }
        }
    }
}
