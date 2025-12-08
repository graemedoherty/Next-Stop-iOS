import Combine
import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var selectedMode: TransportMode? = nil
    @State private var step: Int = 1
    @State private var searchText: String = ""
    @State private var selectedStation: Station? = nil
    @State private var alarmIsSet: Bool = false

    // ✅ NEW: Alert state
    @State private var showCancelAlert: Bool = false

    let allStations: [Station] = {
        let trains = loadStations(from: "trainData", mode: .train)
        let luas = loadStations(from: "luasData", mode: .luas)
        let buses = loadStations(from: "dublinbus", mode: .bus)
        return trains + luas + buses
    }()

    var filteredStations: [Station] {
        guard searchText.count >= 3, let mode = selectedMode else { return [] }
        return allStations.filter {
            $0.mode == mode
                && $0.destination.lowercased().contains(searchText.lowercased())
        }
    }

    // ✅ NEW: Full reset function
    private func resetAppToStep1() {
        withAnimation(.spring()) {
            alarmIsSet = false
            step = 1
            selectedMode = nil
            selectedStation = nil
            searchText = ""
        }
    }

    var body: some View {
        ZStack {
            // Map when alarm is active
            if alarmIsSet,
                let stationLat = Double(selectedStation?.lat ?? ""),
                let stationLong = Double(selectedStation?.long ?? "")
            {

                let testLocation = CLLocationCoordinate2D(
                    latitude: 53.443,
                    longitude: -6.143
                )

                BlackAndWhiteMapView(
                    userLocation: testLocation,
                    stationLat: stationLat,
                    stationLong: stationLong,
                    stationName: selectedStation?.destination ?? ""
                )
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }

            if !alarmIsSet {
                VStack(alignment: .leading, spacing: 24) {

                    // Progress Indicator
                    HStack {
                        StepCircle(number: 1, isActive: step >= 1)
                        Rectangle().frame(height: 3).opacity(
                            step >= 2 ? 1 : 0.3
                        )
                        StepCircle(number: 2, isActive: step >= 2)
                        Rectangle().frame(height: 3).opacity(
                            step >= 3 ? 1 : 0.3
                        )
                        StepCircle(number: 3, isActive: step >= 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .animation(.spring(), value: step)

                    // Step Views with Transitions
                    ZStack {
                        if step == 1 {
                            Step1View(selectedMode: $selectedMode) {
                                withAnimation(.spring()) {
                                    step = 2
                                }
                            }
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                )
                            )
                        }

                        if step == 2 {
                            Step2View(
                                searchText: $searchText,
                                filteredStations: filteredStations
                            ) { station in
                                withAnimation(.spring()) {
                                    selectedStation = station
                                    step = 3
                                }
                            } backAction: {
                                withAnimation(.spring()) {
                                    step = 1
                                    searchText = ""
                                }
                            }
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                )
                            )
                        }

                        if step == 3 {
                            Step3View(
                                station: selectedStation,
                                alarmIsSet: $alarmIsSet,
                                backAction: {
                                    withAnimation(.spring()) {
                                        step = 2
                                        alarmIsSet = false
                                    }
                                }
                            )
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                )
                            )
                        }
                    }

                    Spacer()
                }
            }

            // ✅ Animated Bottom Alarm Card
            if alarmIsSet, let station = selectedStation {
                AlarmBottomCard(
                    stationName: station.destination,
                    distance: "13.2 km",
                    cancelAction: {
                        // ✅ NOW SHOWS ALERT INSTEAD OF IMMEDIATE CANCEL
                        showCancelAlert = true
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(), value: alarmIsSet)

        // ✅ CANCEL CONFIRMATION ALERT
        .alert("Cancel Alarm?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }

            Button("Yes, Cancel", role: .destructive) {
                resetAppToStep1()
            }
        } message: {
            Text("Are you sure you want to cancel your current alarm?")
        }
    }
}

#Preview {
    ContentView()
}

