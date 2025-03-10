import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hydrationProgress: 0.5, exerciseProgress: 0.3)
    }
    
    @available(iOSApplicationExtension 16.0, *)
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), hydrationProgress: getHydrationProgress(), exerciseProgress: getExerciseProgress())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entries = [SimpleEntry(date: Date(), hydrationProgress: getHydrationProgress(), exerciseProgress: getExerciseProgress())]
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(15 * 60))) // Actualiza cada 15 minutos
        completion(timeline)
    }

    func getHydrationProgress() -> Double {
        let sharedDefaults = UserDefaults(suiteName: "group.hidratize.com.disolutionsmx.Hidratize")
        return sharedDefaults?.double(forKey: "hydrationProgress") ?? 0.0
    }

    func getExerciseProgress() -> Double {
        let sharedDefaults = UserDefaults(suiteName: "group.hidratize.com.disolutionsmx.Hidratize")
        return sharedDefaults?.double(forKey: "exerciseProgress") ?? 0.0
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hydrationProgress: Double
    let exerciseProgress: Double
}

@main
struct HidratizeWidget: Widget {
    let kind: String = "HidratizeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HidratizeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hidratize")
        .description("Monitorea tu progreso de hidratación y ejercicio.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
