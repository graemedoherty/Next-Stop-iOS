//
//  MapViewRepresentable.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let userLocation: CLLocationCoordinate2D
    let stationLat: Double
    let stationLong: Double
    let stationName: String
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "You"
        map.addAnnotation(userAnnotation)
        
        let stationCoord = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = stationCoord
        stationAnnotation.title = stationName
        map.addAnnotation(stationAnnotation)
        
        let polyline = MKPolyline(coordinates: [userLocation, stationCoord], count: 2)
        map.addOverlay(polyline)
        
        let userCircle = MKCircle(center: userLocation, radius: 500)
        map.addOverlay(userCircle)
        
        let stationCircle = MKCircle(center: stationCoord, radius: 500)
        map.addOverlay(stationCircle)
        
        let centerLat = (userLocation.latitude + stationLat) / 2
        let centerLong = (userLocation.longitude + stationLong) / 2
        
        let latDelta = abs(userLocation.latitude - stationLat) * 1.5
        let longDelta = abs(userLocation.longitude - stationLong) * 1.5
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.01),
                longitudeDelta: max(longDelta, 0.01)
            )
        )
        map.setRegion(region, animated: true)
        
        map.delegate = context.coordinator
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }
}

class MapCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3
            renderer.lineDashPattern = [5, 5]
            return renderer
        }
        
        if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = .systemBlue
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

