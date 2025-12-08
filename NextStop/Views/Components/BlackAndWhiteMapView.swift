//
//  BlackAndWhiteMapView.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct BlackAndWhiteMapView: View {
    let userLocation: CLLocationCoordinate2D
    let stationLat: Double
    let stationLong: Double
    let stationName: String
    
    var body: some View {
        ZStack {
            MapViewRepresentable(
                userLocation: userLocation,
                stationLat: stationLat,
                stationLong: stationLong,
                stationName: stationName
            )
            
            Rectangle()
                .fill(.black)
                .blendMode(.saturation)
                .opacity(0.8)
        }
    }
}

