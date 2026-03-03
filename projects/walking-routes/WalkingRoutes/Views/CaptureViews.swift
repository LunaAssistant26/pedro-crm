import SwiftUI

enum CaptureScreen {
    case normal
    case home
    case canal
    case jordaan
    case vondelpark
    case navigation
    case demo

    static func fromProcessArguments() -> CaptureScreen {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "--capture-screen"), args.indices.contains(flagIndex + 1) else {
            return .normal
        }

        switch args[flagIndex + 1].lowercased() {
        case "home": return .home
        case "canal": return .canal
        case "jordaan": return .jordaan
        case "vondelpark": return .vondelpark
        case "navigation": return .navigation
        case "demo": return .demo
        default: return .normal
        }
    }
}

struct CaptureRootView: View {
    private let screen: CaptureScreen = .fromProcessArguments()

    var body: some View {
        switch screen {
        case .home:
            ContentView(initialSelectedTime: 45, useLocation: false)
        case .canal:
            NavigationStack { RouteDetailView(route: SampleData.routes[0]) }
        case .jordaan:
            NavigationStack { RouteDetailView(route: SampleData.routes[1]) }
        case .vondelpark:
            NavigationStack { RouteDetailView(route: SampleData.routes[2]) }
        case .navigation:
            NavigationStack { RouteNavigationView(route: SampleData.routes[0], useLocation: false) }
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
        Group {
            switch stage {
            case 0:
                ContentView(initialSelectedTime: 30, useLocation: false)
            case 1:
                ContentView(initialSelectedTime: 60, useLocation: false)
            case 2:
                NavigationStack { RouteDetailView(route: SampleData.routes[0]) }
            case 3:
                NavigationStack { RouteDetailView(route: SampleData.routes[0]) }
            default:
                NavigationStack { RouteNavigationView(route: SampleData.routes[0], useLocation: false) }
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
