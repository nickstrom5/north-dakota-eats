import Foundation
import CoreLocation
import UIKit

/// `-screenshot <name>` opens one screen with fixed state for App Store screenshots (scripts/capture-screenshots.sh).
/// Names: home, knoephla, steaks, honors, oldest, detail, map, saved, about.
enum ScreenshotMode {
    /// Debug builds only: an App Store build ignores the launch argument, so no one can reach seeded screens or fake locations.
    static var name: String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return args[i + 1]
        #else
        return nil
        #endif
    }
    static var isActive: Bool { name != nil }

    @MainActor
    static func apply(to model: AppModel) {
        guard let name, model.isLoaded else { return }
        model.filters = Filters()
        // downtown Fargo, so "nearest" lists have distances without a permission prompt
        model.screenshotLocation = CLLocation(latitude: 46.8772, longitude: -96.7898)
        // by name and town, ignoring case, so a rebuild with a slightly different casing still finds the place; the hand-checked one first
        let pick = { (n: String, town: String?) -> Place? in
            let hits = model.places.filter { $0.name.caseInsensitiveCompare(n) == .orderedSame && (town == nil || $0.city == town) }
            return hits.first(where: \.handChecked) ?? hits.first
        }
        for p in [pick("Kroll's Diner", "Fargo"), pick("Wurst Bier Hall", "Fargo"), pick("Theodore's Dining Room", "Medora")]
            .compactMap({ $0 }) where !model.isSaved(p) {
            model.toggleSaved(p)
        }
        let open = { (g: Guide) in model.tab = .guides; model.selectedGuide = g; model.guidesPath = [.guide(g)] }
        switch name {
        case "knoephla":
            // south Fargo, near Kroll's Diner
            model.screenshotLocation = CLLocation(latitude: 46.8600, longitude: -96.8400)
            open(.knoephla)
        case "steaks":
            // downtown Grand Forks
            model.screenshotLocation = CLLocation(latitude: 47.9253, longitude: -97.0329)
            open(.steaks)
        case "honors": open(.honors)
        case "oldest": open(.oldest)
        case "detail":
            // Kroll's Diner in Fargo: knoephla, fleischkuechle and kuchen, with its notes
            model.screenshotLocation = CLLocation(latitude: 46.8600, longitude: -96.8400)
            open(.knoephla)
            if let p = pick("Kroll's Diner", "Fargo") ?? model.places.first {
                model.selectedPlace = p; model.guidesPath.append(.place(p))
            }
        case "map": model.tab = .map
        case "saved": model.tab = .saved
        case "about": model.tab = .about
        default: model.tab = .guides; model.selectedGuide = nil
        }
        // iPad shows the place column next to every list, so give each shot a place instead of "Pick a place": a different
        // honored or hand-checked one per shot.
        guard UIDevice.current.userInterfaceIdiom == .pad, model.selectedPlace == nil else { return }
        let place: Place? = switch name {
        case "home": pick("Wurst Bier Hall", "Fargo")
        case "knoephla": pick("Darcy's Cafe", "Grand Forks")
        case "steaks": pick("Harry's Steakhouse", "Grand Forks")
        case "map": pick("Kroll's Diner", "Fargo")
        case "honors": pick("Luna Fargo", "Fargo")
        case "oldest": pick("Kroll's Diner", "Fargo")
        case "saved": pick("Kroll's Diner", "Fargo")
        case "about": nil
        default: pick("Kroll's Diner", "Fargo")
        }
        model.selectedPlace = place
    }
}
