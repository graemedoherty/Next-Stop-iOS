////
////  NextStopLiveActivity.swift
////  NextStop
////
//// PURPOSE: Renders Live Activity on Lock Screen and Dynamic Island
//// No widget - just Live Activity for lock screen notifications
////
//
//import ActivityKit
//import WidgetKit
//import SwiftUI
//
//struct NextStopLiveActivity: Widget {
//    let kind: String = "NextStopLiveActivity"
//    
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: NextStopAttributes.self) { context in
//            // LOCK SCREEN VIEW
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    Text("Alarm Active")
//                        .foregroundColor(.green)
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    Image(systemName: "location.fill")
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                }
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(context.attributes.destinationName)
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .lineLimit(1)
//                }
//                
//                HStack(alignment: .bottom, spacing: 12) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Distance")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        Text(context.state.distance)
//                            .font(.system(size: 32, weight: .bold, design: .default))
//                            .foregroundColor(.green)
//                    }
//                    Spacer()
//                    Button("Cancel Alarm") {
//                    }
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color.red)
//                    .cornerRadius(8)
//                }
//            }
//            .padding()
//            .background(Color.black.opacity(0.3))
//            .cornerRadius(16)
//            
//        } dynamicIsland: { context in
//            // DYNAMIC ISLAND
//            DynamicIsland {
//                // EXPANDED VIEW
//                DynamicIslandExpandedRegion(.leading) {
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text("Destination")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text(context.attributes.destinationName)
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .lineLimit(1)
//                            .foregroundColor(.blue)
//                    }
//                }
//                
//                DynamicIslandExpandedRegion(.trailing) {
//                    VStack(alignment: .trailing, spacing: 6) {
//                        Text("Distance")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text(context.state.distance)
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundColor(.green)
//                    }
//                }
//                
//                DynamicIslandExpandedRegion(.center) {
//                    VStack(spacing: 8) {
//                        Text(context.state.status)
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                        
//                        Button("Cancel Alarm") {
//                        }
//                        .font(.caption2)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 4)
//                        .background(Color.red)
//                        .cornerRadius(6)
//                    }
//                }
//                
//            } compactLeading: {
//                // COMPACT VIEW - Left
//                HStack(spacing: 4) {
//                    Image(systemName: "location.fill")
//                        .font(.caption2)
//                        .foregroundColor(.blue)
//                    Text(context.attributes.destinationName)
//                        .font(.caption2)
//                        .fontWeight(.bold)
//                        .lineLimit(1)
//                        .foregroundColor(.blue)
//                }
//            } compactTrailing: {
//                // COMPACT VIEW - Right
//                HStack(spacing: 4) {
//                    Image(systemName: "location.fill")
//                        .font(.caption2)
//                        .foregroundColor(.blue)
//                    Text(context.state.distance)
//                        .font(.caption2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
//                }
//            } minimal: {
//                // MINIMAL VIEW
//                Image(systemName: "location.fill")
//                    .foregroundColor(.blue)
//            }
//        }
//    }
//}
//
//// MARK: - Previews
//#Preview("Lock Screen") {
//    VStack(alignment: .leading, spacing: 12) {
//        HStack {
//            Text("Alarm Active")
//                .foregroundColor(.green)
//                .font(.caption)
//                .fontWeight(.semibold)
//            Spacer()
//            Image(systemName: "location.fill")
//                .font(.caption)
//                .foregroundColor(.blue)
//        }
//        
//        VStack(alignment: .leading, spacing: 2) {
//            Text("Dublin Central")
//                .font(.headline)
//                .fontWeight(.bold)
//                .lineLimit(1)
//        }
//        
//        HStack(alignment: .bottom, spacing: 12) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Distance")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text("2.3 km")
//                    .font(.system(size: 32, weight: .bold, design: .default))
//                    .foregroundColor(.green)
//            }
//            Spacer()
//            Button("Cancel Alarm") {
//            }
//            .font(.caption)
//            .fontWeight(.semibold)
//            .foregroundColor(.white)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(Color.red)
//            .cornerRadius(8)
//        }
//    }
//    .padding()
//    .background(Color.black.opacity(0.3))
//    .cornerRadius(16)
//}
//
//#Preview("Island - Compact") {
//    HStack(spacing: 8) {
//        HStack(spacing: 4) {
//            Image(systemName: "location.fill")
//                .font(.caption2)
//                .foregroundColor(.blue)
//            Text("Dublin Central")
//                .font(.caption2)
//                .fontWeight(.bold)
//                .lineLimit(1)
//                .foregroundColor(.blue)
//        }
//        Spacer()
//        HStack(spacing: 4) {
//            Image(systemName: "location.fill")
//                .font(.caption2)
//                .foregroundColor(.blue)
//            Text("2.3 km")
//                .font(.caption2)
//                .fontWeight(.bold)
//                .foregroundColor(.blue)
//        }
//    }
//    .padding(8)
//    .background(Color.black)
//    .cornerRadius(20)
//}
//
//#Preview("Island - Expanded") {
//    VStack(alignment: .leading, spacing: 12) {
//        HStack {
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Destination")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Text("Dublin Central")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .lineLimit(1)
//                    .foregroundColor(.blue)
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 6) {
//                Text("Distance")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Text("2.3 km")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .foregroundColor(.green)
//            }
//        }
//        
//        VStack(spacing: 8) {
//            Text("On the way")
//                .font(.subheadline)
//                .fontWeight(.semibold)
//            
//            Button("Cancel Alarm") {
//            }
//            .font(.caption2)
//            .fontWeight(.semibold)
//            .foregroundColor(.white)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 4)
//            .background(Color.red)
//            .cornerRadius(6)
//        }
//    }
//    .padding()
//    .background(Color.black)
//    .cornerRadius(20)
//}
