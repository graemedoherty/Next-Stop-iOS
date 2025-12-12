//
//  StatusWidgetLiveActivity.swift
//  StatusWidget Extension
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StatusWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextStopAttributes.self) { context in

            // MARK: LOCK SCREEN UI
            VStack(alignment: .leading, spacing: 12) {

                // Header
                HStack {
                    Text(context.state.hasArrived ? "Arrived" : "Active Alarm")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(context.state.hasArrived ? .blue : .green)

                    Spacer()

                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                // Destination
                Text(context.attributes.destinationName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                // Distance + Cancel
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(context.state.distance)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(context.state.hasArrived ? .blue : .green)
                            .monospacedDigit()
                    }

                    Spacer()

                    Link(destination: URL(string: "nextstop://cancelAlarm")!) {
                        Text("Cancel Alarm")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(.blue)

        } dynamicIsland: { context in

            // MARK: EXPANDED DYNAMIC ISLAND
            DynamicIsland {

                // Entire expanded island is in the center region for full-width layout
                DynamicIslandExpandedRegion(.center) {

                    VStack(spacing: 14) {

                        // ROW 1 — Destination + Distance
                        HStack {
                            // Destination
                            Text(context.attributes.destinationName)
                                .font(.title)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // Distance
                            Text(context.state.distance)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(context.state.hasArrived ? .blue : .green)
                                .monospacedDigit()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 10) // clears top curve

                       
                        // ROW 2 — Centered Status + Cancel
                        HStack {
                            // Active Alarm / Arrived
                            Text(context.state.hasArrived ? "Arrived" : "Active Alarm")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(context.state.hasArrived ? .blue : .green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            // Cancel Button
                            Link(destination: URL(string: "nextstop://cancelAlarm")!) {
                                Text("Cancel")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .cornerRadius(6)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 10)

                    }
                }

                // Bottom region — slim progress bar
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView()
                        .progressViewStyle(.linear)
                }

            } compactLeading: {

                // COMPACT LEADING
                Text(context.state.hasArrived ? "Arrived" : "Active")
                    .font(.caption2)
                    .foregroundColor(context.state.hasArrived ? .blue : .green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

            } compactTrailing: {

                // COMPACT TRAILING
                Text(context.state.distance)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(context.state.hasArrived ? .blue : .green)
                    .monospacedDigit()

            } minimal: {

                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}


// MARK: - STATIC PREVIEWS
struct LiveActivityLockScreenPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Alarm")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                Spacer()
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            Text("Dublin Connolly")
                .font(.title3)
                .bold()
            HStack {
                VStack(alignment: .leading) {
                    Text("Distance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("1.2 km")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.green)
                }
                Spacer()
                Text("Cancel Alarm")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview("Lock Screen UI") {
    LiveActivityLockScreenPreview().previewLayout(.sizeThatFits)
}

