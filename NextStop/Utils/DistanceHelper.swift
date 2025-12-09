//
//  DistanceHelper.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//


import CoreLocation

struct DistanceHelper {
    
    static func distanceInMeters(
        userLat: Double,
        userLong: Double,
        stationLat: Double,
        stationLong: Double
    ) -> Double {
        
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)
        let stationLocation = CLLocation(latitude: stationLat, longitude: stationLong)
        
        return userLocation.distance(from: stationLocation)
    }
    
    static func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}

