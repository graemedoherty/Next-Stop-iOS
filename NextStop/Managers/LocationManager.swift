//
//  LocationManager.swift
//  NextStop
//
// PURPOSE: Handles location tracking, alarm detection, and Live Activity management
//

import Foundation
import CoreLocation
import ActivityKit
import Combine
import AVFoundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var distanceToStation: Double?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    // MARK: - Callbacks
    var onAlarmTriggered: (() -> Void)?
    
    // MARK: - Private Properties
    private(set) var destinationStation: Station?
    private let manager = CLLocationManager()
    private var audioPlayer: AVAudioPlayer?
    private var simulationTimer: Timer?
    
    // Live Activity properties
    private var currentActivity: Activity<NextStopAttributes>?
    private var lastActivityUpdateLocation: CLLocationCoordinate2D?
    
    private var hasTriggered = false
    var activationRadius: Double = 100
    
    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.activityType = .automotiveNavigation
    }
    
    // MARK: - Permissions
    func requestLocationPermission() {
        print("📍 Requesting location permission...")
        manager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        print("📍 Requesting always location permission...")
        manager.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Updates
    func startUpdating() {
        print("📍 Starting location updates...")
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        print("📍 Stopping location updates...")
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Destination Management
    func setDestinationStation(_ station: Station) {
        print("📍 Set destination: \(station.destination)")
        destinationStation = station
        distanceToStation = nil
        hasTriggered = false
    }
    
    func clearDestination() {
        print("📍 Cleared destination")
        destinationStation = nil
        distanceToStation = nil
        stopAlarmSound()
        stopSimulating()
        endLiveActivity()
    }
    
    // MARK: - Simulation
    func startSimulatingJourney() {
        guard let station = destinationStation,
              let lat = Double(station.lat),
              let long = Double(station.long) else { return }
        
        let startLocation = CLLocationCoordinate2D(latitude: 53.4509, longitude: -6.1501)
        let endLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        print("🚗 Starting journey simulation...")
        simulationTimer?.invalidate()
        simulationTimer = LocationSimulator.simulateJourneyToward(
            from: startLocation,
            to: endLocation,
            stepMeters: 50
        ) { [weak self] coord in
            DispatchQueue.main.async {
                self?.userLocation = coord
                self?.evaluateDistanceAndTriggerIfNeeded()
                self?.updateLiveActivityIfNeeded()
            }
        }
    }
    
    func stopSimulating() {
        simulationTimer?.invalidate()
        simulationTimer = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Authorization changed to: \(manager.authorizationStatus.rawValue)")
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if destinationStation != nil {
                startUpdating()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
            print("📍 User location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            self.evaluateDistanceAndTriggerIfNeeded()
            self.updateLiveActivityIfNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
    }
    
    // MARK: - Distance & Alarm Logic
    private func evaluateDistanceAndTriggerIfNeeded() {
        guard let dest = destinationStation,
              let userLoc = userLocation,
              let lat = Double(dest.lat),
              let long = Double(dest.long) else { return }
        
        let distance = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            .distance(from: CLLocation(latitude: lat, longitude: long))
        
        DispatchQueue.main.async {
            self.distanceToStation = distance
            print("📍 Distance to \(dest.destination): \(String(format: "%.0f", distance))m")
        }
        
        if distance <= activationRadius && !hasTriggered {
            hasTriggered = true
            print("🚨 ALARM TRIGGERED at \(String(format: "%.0f", distance))m!")
            DispatchQueue.main.async {
                self.onAlarmTriggered?()
            }
            endLiveActivity()
        }
    }
    
    // MARK: - Audio
    func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("⚠️ alarm.mp3 not found")
            return
        }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
    
    func stopAlarmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // MARK: - Live Activity Management
    
    /// START: Creates and displays Live Activity on lock screen
    func startLiveActivity(for station: Station, modeDisplayName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities not enabled on this device")
            return
        }
        
        if currentActivity != nil {
            print("⚠️ Activity already running, skipping...")
            return
        }
        
        let attributes = NextStopAttributes(
            destinationName: station.destination
        )

        let initialState = NextStopAttributes.ContentState(
            distance: "Loading...",
            hasArrived: false
        )

        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                contentState: initialState
            )
            print("✅ Live Activity started for \(station.destination)")
        } catch {
            print("❌ Failed to start Live Activity:", error)
        }
    }
    
    /// UPDATE: Called every location update to refresh lock screen display
    func updateLiveActivityIfNeeded() {
        guard let activity = currentActivity,
              let userLoc = userLocation,
              let dest = destinationStation,
              let lat = Double(dest.lat),
              let long = Double(dest.long) else { return }
        
        // Only update every 100 meters to avoid excessive updates
        if let last = lastActivityUpdateLocation {
            let distanceMoved = CLLocation(latitude: last.latitude, longitude: last.longitude)
                .distance(from: CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude))
            if distanceMoved < 100 { return }
        }
        lastActivityUpdateLocation = userLoc
        
        let distanceMeters = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
            .distance(from: CLLocation(latitude: lat, longitude: long))
        
        // Format distance: meters if < 1000m, otherwise kilometers
        let distanceString: String
        if distanceMeters < 1000 {
            // Show in meters (no decimal)
            distanceString = String(format: "%.0f m", distanceMeters)
        } else {
            // Show in kilometers (1 decimal place, updates every 100 meters)
            let distanceKm = distanceMeters / 1000
            distanceString = String(format: "%.1f km", distanceKm)
        }
        
        let arrived = distanceMeters < activationRadius

        let newState = NextStopAttributes.ContentState(
            distance: distanceString,
            hasArrived: arrived
        )

        
        Task {
            await activity.update(using: newState)
            print("🔁 Live Activity updated: \(distanceString)")
        }
    }
    
    /// END: Terminates Live Activity when alarm triggers or user cancels
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            let finalState = NextStopAttributes.ContentState(
                distance: "0 m",
                hasArrived: true
            )

            await activity.end(using: finalState, dismissalPolicy: .immediate)
            currentActivity = nil
            print("🛑 Live Activity ended")
        }
    }
}
