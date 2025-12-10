//
//  LocationManager.swift
//  NextStop
//
//  Created by ChatGPT on 2025-12-10.
//

import Foundation
import CoreLocation
import ActivityKit
import Combine
import AVFoundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var distanceToStation: Double?
    @Published var authorizationStatus: CLAuthorizationStatus?

    // Alarm callback
    var onAlarmTriggered: (() -> Void)?

    // Destination
    private(set) var destinationStation: Station?

    // Core Location
    private let manager = CLLocationManager()

    // Audio (simple alarm placeholder)
    private var audioPlayer: AVAudioPlayer?

    // Simulation timer (for simulator testing)
    private var simulationTimer: Timer?

    // Live Activity handle
    private var currentActivity: Activity<NextStopAttributes>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // leave allowsBackgroundLocationUpdates true only if entitlements/info.plist set
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .automotiveNavigation
    }

    // MARK: - Permissions
    func requestLocationPermission() {
        print("📍 Requesting location permission...")
        // ask for when-in-use first; you can later call requestAlwaysAuthorization() after explaining to user
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysPermission() {
        print("📍 Requesting ALWAYS permission...")
        manager.requestAlwaysAuthorization()
    }

    // MARK: - Start / Stop updates
    func startUpdating() {
        print("📍 Starting location updates...")
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        print("📍 Stopping location updates...")
        manager.stopUpdatingLocation()
    }

    // MARK: - Destination control (used by ContentView)
    func setDestinationStation(_ station: Station) {
        print("📍 Destination set: \(station.destination)")
        destinationStation = station
        distanceToStation = nil
        hasTriggered = false
        // do not start updates here directly; ContentView decides (simulator vs real)
    }

    func clearDestination() {
        print("📍 Clearing destination")
        destinationStation = nil
        distanceToStation = nil
        stopAlarmSound()
        stopSimulating()
        endLiveActivity()
    }

    // MARK: - Simulation (for simulator/testing)
    func startSimulatingJourney() {
        guard let station = destinationStation,
              let lat = Double(station.lat),
              let long = Double(station.long) else {
            print("No station to simulate to")
            return
        }

        let startLocation = CLLocationCoordinate2D(latitude: 53.4509, longitude: -6.1501) // sample start
        let endLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)

        simulationTimer?.invalidate()
        simulationTimer = LocationSimulator.simulateJourneyToward(from: startLocation, to: endLocation, stepMeters: 50) { [weak self] coord in
            DispatchQueue.main.async {
                self?.userLocation = coord
                self?.evaluateDistanceAndTriggerIfNeeded()
                self?.updateLiveActivityIfNeeded()
            }
        }
        print("🚗 Simulation started")
    }

    func stopSimulating() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Authorization changed to: \(authorizationStatus?.rawValue ?? -1)")
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // start updates only if we have a destination (ContentView controls behavior)
            if destinationStation != nil {
                startUpdating()
            }
        } else {
            print("❌ Location permission DENIED or UNDETERMINED")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
            self.evaluateDistanceAndTriggerIfNeeded()
            self.updateLiveActivityIfNeeded()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
    }

    // MARK: - Distance evaluation & Alarm
    private var hasTriggered = false
    var activationRadius: Double = 200 // meters (you used 200 earlier; change as required)

    private func evaluateDistanceAndTriggerIfNeeded() {
        guard let dest = destinationStation,
              let userLoc = userLocation,
              let stationLat = Double(dest.lat),
              let stationLong = Double(dest.long)
        else { return }

        let userCL = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let stationCL = CLLocation(latitude: stationLat, longitude: stationLong)
        let distance = userCL.distance(from: stationCL)

        DispatchQueue.main.async {
            self.distanceToStation = distance
        }

        // Update live activity continuously (handled elsewhere)
        if distance <= activationRadius && !hasTriggered {
            hasTriggered = true
            print("🚨 ALARM TRIGGER at \(Int(distance))m for \(dest.destination)")
            // fire callback for UI popup in ContentView
            DispatchQueue.main.async {
                self.onAlarmTriggered?()
            }
            // play alarm sound (if you want)
            // playAlarmSound()
            // end live activity after triggered
            endLiveActivity()
        }
    }

    // MARK: - Audio (optional)
    func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing alarm:", error)
        }
    }

    func stopAlarmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Live Activity control (ActivityKit)
    func startLiveActivity(for station: Station, modeDisplayName: String) {
        let authorizationInfo = ActivityAuthorizationInfo()
        guard authorizationInfo.areActivitiesEnabled else {
            print("⚠️ Live Activities not allowed/enabled on device")
            return
        }

        // do not start twice
        if currentActivity != nil { return }

        let attributes = NextStopAttributes(lineName: modeDisplayName, destinationName: station.destination)
        let initialState = NextStopAttributes.ContentState(distance: "--", status: "On the way")

        do {
            let activity = try Activity.request(attributes: attributes, contentState: initialState)
            currentActivity = activity
            print("✅ Live Activity started: \(activity.id)")
        } catch {
            print("❌ Failed to start Live Activity:", error)
        }
    }


    private func updateLiveActivityIfNeeded() {
        guard let activity = currentActivity,
              let userLoc = userLocation,
              let dest = destinationStation,
              let lat = Double(dest.lat),
              let long = Double(dest.long) else { return }

        let userCL = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let stationCL = CLLocation(latitude: lat, longitude: long)
        let distance = userCL.distance(from: stationCL)
        let distanceString = String(format: "%.0f m", distance)
        let statusString = distance < activationRadius ? "Arriving" : "On the way"

        let updated = NextStopAttributes.ContentState(distance: distanceString, status: statusString)
        Task {
            await activity.update(using: updated)
            // no print here to avoid spam
        }
    }

    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(using: NextStopAttributes.ContentState(distance: "0 m", status: "Arrived"), dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}

