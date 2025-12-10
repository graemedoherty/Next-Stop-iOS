//
//  StatusWidget.swift
//  StatusWidget (extension)
//

import WidgetKit
import SwiftUI

// MARK: - Widget Definition
struct StatusWidget: Widget {
    let kind: String = "StatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            StatusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("NextStop Status")
        .description("Shows quick status and launches the app.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entries = [SimpleEntry()]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date

    init(date: Date = Date()) {
        self.date = date
    }
}

// MARK: - Widget View
struct StatusWidgetEntryView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NextStop")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Open app to set alarm")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        // ✅ Modern iOS 17 container background
        .containerBackground(for: .widget) {
            Color(.systemBackground) // Can replace with .ultraThinMaterial if desired
        }
    }
}

// MARK: - Preview
struct StatusWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatusWidgetEntryView(entry: SimpleEntry())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
