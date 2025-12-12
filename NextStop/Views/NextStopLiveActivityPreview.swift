//
//  NextStopLiveActivityPreview.swift
//  NextStop
//

import SwiftUI
import ActivityKit

@available(iOS 17.0, *)
struct NextStopLiveActivityPreviewWrapper: View {

    let attributes = NextStopAttributes(destinationName: "Dublin Connolly")

    let stateKm = NextStopAttributes.ContentState(distance: "1.9 km", hasArrived: false)
    let stateM  = NextStopAttributes.ContentState(distance: "850 m", hasArrived: false)
    let stateArrived = NextStopAttributes.ContentState(distance: "0 m", hasArrived: true)

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // LOCK SCREEN MOCK
                VStack(alignment: .leading, spacing: 12) {

                    HStack {
                        Text(stateKm.hasArrived ? "Arrived" : "Active Alarm")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(stateKm.hasArrived ? .blue : .green)

                        Spacer()

                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    Text(attributes.destinationName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(stateKm.distance)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(stateKm.hasArrived ? .blue : .green)
                        }

                        Spacer()

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
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)


                // EXPANDED ISLAND MOCK
                VStack(spacing: 16) {

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Destination")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(attributes.destinationName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Distance")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(stateKm.distance)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .monospacedDigit()
                        }
                    }

                    HStack {
                        Text(stateKm.hasArrived ? "Arrived" : "Active Alarm")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("Cancel")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(6)
                            .foregroundColor(.white)
                    }

                    ProgressView(value: stateKm.hasArrived ? 1.0 : 0.5)
                        .progressViewStyle(.linear)
                }
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(20)
                .padding(.horizontal)


                // CLOSE RANGE MOCK
                VStack(alignment: .leading, spacing: 8) {
                    Text("Close Range Example")
                        .font(.headline)

                    HStack {
                        Text(attributes.destinationName)
                        Spacer()
                        Text(stateM.distance)
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // ARRIVED MOCK
                VStack(alignment: .leading, spacing: 8) {

                    HStack {
                        Text("Arrived")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }

                    Text(attributes.destinationName)
                        .font(.title3)
                        .bold()

                    Text("0 m")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

            }
            .padding(.vertical, 32)
        }
    }
}

@available(iOS 17.0, *)
struct NextStopLiveActivityPreviewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NextStopLiveActivityPreviewWrapper()

            NextStopLiveActivityPreviewWrapper()
                .preferredColorScheme(.dark)
        }
    }
}
