//
//  StatusWidgetLiveActivity.swift
//  StatusWidget (extension)
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StatusWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextStopAttributes.self) { context in
            // Lock screen / banner UI
            VStack(alignment: .leading, spacing: 8) {
                Text("\(context.attributes.lineName) • NextStop")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    VStack(alignment: .leading) {
                        Text(context.attributes.destinationName)
                            .font(.headline)
                        Text(context.state.status)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(context.state.distance)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded center region
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.destinationName).font(.headline)
                        Text(context.state.status).font(.subheadline)
                    }
                }
            } compactLeading: {
                Text("Next")
                    .font(.caption2)
            } compactTrailing: {
                Text(context.state.distance)
                    .font(.caption2)
            } minimal: {
                Text("•")
            }
        }
    }
}

