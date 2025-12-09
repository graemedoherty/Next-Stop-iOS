//
//  ContentView.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine


struct ContentView: View {
    // LOCATION MANAGER
    @EnvironmentObject var locationManager: LocationManager

    // App state
    @State private var selectedMode: TransportMode? = nil
    @State private var step: Int = 1
    @State private var searchText: String = ""
    @State private var selectedStation: Station? = nil
    @State private var alarmIsSet: Bool = false
    
    // Alerts
    @State private var showCancelAlert: Bool = false
    @State private var showAlarmTriggeredAlert: Bool = false
    
    // Stations loaded from bundle
    let allStations: [Station] = {
        let trains = loadStations(from: "trainData", mode: .train)
        let luas = loadStations(from: "luasData", mode: .luas)
        return trains + luas
    }()
    
    var filteredStations: [Station] {
        guard searchText.count >= 3, let mode = selectedMode else { return [] }
        return allStations.filter {
            $0.mode == mode && $0.destination.lowercased().contains(searchText.lowercased())
        }
    }
    
    // Reset helper
    private func resetAppToStep1() {
        withAnimation(.spring()) {
            alarmIsSet = false
            step = 1
            selectedMode = nil
            selectedStation = nil
            searchText = ""
        }
        locationManager.clearDestination()
        locationManager.stopAlarmSound()
        locationManager.stopUpdating()
    }
    
    var body: some View {
        ZStack {
            // When alarm is active show map
            if alarmIsSet,
               let stationLat = Double(selectedStation?.lat ?? ""),
               let stationLong = Double(selectedStation?.long ?? "") {
                
                let fallback = CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603)
                let userLoc = locationManager.userLocation ?? fallback
                
                BlackAndWhiteMapView(
                    userLocation: userLoc,
                    stationLat: stationLat,
                    stationLong: stationLong,
                    stationName: selectedStation?.destination ?? ""
                )
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            }
            
            // Main flow (steps)
            if !alarmIsSet {
                VStack(alignment: .leading, spacing: 24) {
                    // Progress indicator
                    HStack {
                        StepCircle(number: 1, isActive: step >= 1)
                        Rectangle().frame(height: 3).opacity(step >= 2 ? 1 : 0.3)
                        StepCircle(number: 2, isActive: step >= 2)
                        Rectangle().frame(height: 3).opacity(step >= 3 ? 1 : 0.3)
                        StepCircle(number: 3, isActive: step >= 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Steps with asymmetric transitions
                    ZStack {
                        if step == 1 {
                            Step1View(selectedMode: $selectedMode) {
                                withAnimation(.spring()) { step = 2 }
                            }
                            .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                    removal: .move(edge: .leading)))
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
                            .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                    removal: .move(edge: .leading)))
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
                            .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                    removal: .move(edge: .leading)))
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Bottom alarm card
            if alarmIsSet,
               let station = selectedStation,
               let stationLat = Double(station.lat),
               let stationLong = Double(station.long) {
                
                let fallback = CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603)
                let userLoc = locationManager.userLocation ?? fallback
                
                let distance = DistanceHelper.distanceInMeters(
                    userLat: userLoc.latitude,
                    userLong: userLoc.longitude,
                    stationLat: stationLat,
                    stationLong: stationLong
                )
                
                AlarmBottomCard(
                    stationName: station.destination,
                    distanceMeters: distance,
                    cancelAction: {
                        withAnimation(.spring()) { showCancelAlert = true }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            locationManager.requestLocationPermission()
        }
        .onChange(of: alarmIsSet) { newValue in
            if newValue {
                if let station = selectedStation {
                    locationManager.setDestinationStation(station)
                    locationManager.startSimulatingJourney()  // ✅ START SIMULATION
                    locationManager.onAlarmTriggered = {
                        print("🔔 ALARM TRIGGERED - Station approaching!")
                        showAlarmTriggeredAlert = true
                    }
                }
            } else {
                locationManager.clearDestination()
                locationManager.stopAlarmSound()
            }
        }
        // Cancel confirmation alert
        .alert("Cancel Alarm?", isPresented: $showCancelAlert) {
            Button("No", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                resetAppToStep1()
            }
        } message: {
            Text("Are you sure you want to cancel your current alarm?")
        }
        // Alarm triggered alert
        .alert("Station Approaching!", isPresented: $showAlarmTriggeredAlert) {
            Button("OK") {
                showAlarmTriggeredAlert = false
            }
        } message: {
            Text("\(selectedStation?.destination ?? "Your station") is within 100 meters!")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
