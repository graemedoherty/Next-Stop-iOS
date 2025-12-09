//
//  LocationSimulator.swift
//  NextStop
//
//  Created by Graeme Doherty on 09/12/2025.
//
  

import Foundation
import CoreLocation

class LocationSimulator {
    static func simulateJourneyToward(
        from startCoord: CLLocationCoordinate2D,
        to endCoord: CLLocationCoordinate2D,
        stepMeters: Double = 50,
        onLocationUpdate: @escaping (CLLocationCoordinate2D) -> Void
    ) -> Timer {
        var currentLocation = startCoord
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Calculate distance remaining
            let currentCL = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            let endCL = CLLocation(latitude: endCoord.latitude, longitude: endCoord.longitude)
            let distanceRemaining = currentCL.distance(from: endCL)
            
            // Stop if we've arrived
            if distanceRemaining < stepMeters {
                onLocationUpdate(endCoord)
                return
            }
            
            // Calculate bearing and move toward destination
            let latDiff = endCoord.latitude - currentLocation.latitude
            let longDiff = endCoord.longitude - currentLocation.longitude
            let distance = sqrt(latDiff * latDiff + longDiff * longDiff)
            
            let ratio = stepMeters / (distance * 111000) // 111km per degree
            currentLocation.latitude += latDiff * ratio
            currentLocation.longitude += longDiff * ratio
            
            onLocationUpdate(currentLocation)
        }
        
        return timer
    }
}
