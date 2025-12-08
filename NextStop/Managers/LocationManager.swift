//
//  LocationManager.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published Properties
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userHeading: CLHeading?
    @Published var distanceToDestination: Double?   // ✅ Live distance in meters
    @Published var hasReachedDestination: Bool = false
    
    // MARK: - Private
    private let locationManager = CLLocationManager()
    private var destinationLocation: CLLocation?
    
    // Alarm trigger radius (you can tweak this later)
    private let triggerRadius: Double = 500 // meters
    
    // MARK: - Init
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // update every 5m movement
        locationManager.allowsBackgroundLocationUpdates = true // ✅ background
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Permissions
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        
        // You will later upgrade this to:
        // locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Control
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - Destination Tracking
    func setDestination(lat: Double, long: Double) {
        destinationLocation = CLLocation(latitude: lat, longitude: long)
        hasReachedDestination = false
    }
    
    func clearDestination() {
        destinationLocation = nil
        distanceToDestination = nil
        hasReachedDestination = false
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            
            // ✅ LIVE DISTANCE CALCULATION
            if let destination = self.destinationLocation {
                let distance = location.distance(from: destination)
                self.distanceToDestination = distance
                
                // ✅ PROXIMITY CHECK (Alarm Trigger Hook)
                if distance <= self.triggerRadius {
                    self.hasReachedDestination = true
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.userHeading = newHeading
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            print("❌ Location access denied")
        default:
            break
        }
    }
}
