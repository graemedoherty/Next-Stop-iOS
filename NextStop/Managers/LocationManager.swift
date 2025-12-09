import Foundation
import CoreLocation
import SwiftUI
import Combine
import AVFoundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var audioPlayer: AVAudioPlayer?
    private var simulationTimer: Timer?  // ✅ Add this

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var distanceToStation: Double?
    @Published var hasTriggeredAlarm: Bool = false

    // Alarm settings
    var destinationStation: Station?
    var activationRadius: Double = 100
    var onAlarmTriggered: (() -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = false
    }

    // MARK: - Permissions
    func requestLocationPermission() {
        print("📍 Requesting location permission...")
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - Updating
    func startUpdating() {
        print("📍 Starting location updates...")
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        print("📍 Stopping location updates...")
        manager.stopUpdatingLocation()
        simulationTimer?.invalidate()  // ✅ Stop simulation if running
        simulationTimer = nil
    }

    // MARK: - Destination
    func setDestinationStation(_ station: Station) {
        print("📍 Set destination: \(station.destination)")
        self.destinationStation = station
        self.hasTriggeredAlarm = false
    }

    func clearDestination() {
        print("📍 Cleared destination")
        self.destinationStation = nil
        self.hasTriggeredAlarm = false
        self.distanceToStation = nil
        simulationTimer?.invalidate()  // ✅ Stop simulation
        simulationTimer = nil
    }
    
    // ✅ NEW: Simulate journey for testing
    func startSimulatingJourney() {
        guard let station = destinationStation,
              let stationLat = Double(station.lat),
              let stationLong = Double(station.long) else { return }
        
        let stationCoord = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)
        
        // Start from Dublin city center
        let startLocation = CLLocationCoordinate2D(latitude: 53.4509, longitude: -6.1501)
        
        print("🚗 Starting journey simulation from \(startLocation) to \(stationCoord)")
        
        simulationTimer = LocationSimulator.simulateJourneyToward(
            from: startLocation,
            to: stationCoord,
            stepMeters: 50
        ) { [weak self] newLocation in
            DispatchQueue.main.async {
                self?.userLocation = newLocation
                if let station = self?.destinationStation {
                    self?.checkDistanceAndTriggerAlarm(userLocation: newLocation, station: station)
                }
            }
        }
    }

    // MARK: - Authorization Callbacks
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Authorization changed to: \(manager.authorizationStatus.rawValue)")

        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            print("✅ Permission GRANTED – safe to start location updates")
            if destinationStation != nil {
                startUpdating()
            }
        } else {
            print("❌ Location permission DENIED or UNDETERMINED")
        }
    }

    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            print("📍 User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")

            if let station = self.destinationStation {
                self.checkDistanceAndTriggerAlarm(userLocation: location.coordinate, station: station)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error:", error.localizedDescription)
    }

    // MARK: - Alarm Logic
    private func checkDistanceAndTriggerAlarm(userLocation: CLLocationCoordinate2D, station: Station) {
        guard let stationLat = Double(station.lat),
              let stationLong = Double(station.long) else { return }

        let stationCoord = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)
        let distance = self.calculateDistance(from: userLocation, to: stationCoord)

        DispatchQueue.main.async {
            self.distanceToStation = distance
            print("📍 Distance to \(station.destination): \(String(format: "%.0f", distance))m")
        }

        if distance <= self.activationRadius && !self.hasTriggeredAlarm {
            DispatchQueue.main.async {
                self.hasTriggeredAlarm = true
                print("🚨 ALARM TRIGGERED at \(String(format: "%.0f", distance))m!")
                self.onAlarmTriggered?()
            }
        }
    }

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    func stopAlarmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
