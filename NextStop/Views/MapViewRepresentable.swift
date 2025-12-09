//
// MapViewRepresentable.swift
// NextStop
//
// Updated: dynamic annotations/overlays + blue pins
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    let userLocation: CLLocationCoordinate2D
    let stationLat: Double
    let stationLong: Double
    let stationName: String
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.showsUserLocation = false
        map.isRotateEnabled = false
        map.pointOfInterestFilter = .excludingAll
        map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .flat)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove old dynamic overlays + annotations (we keep static map settings)
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        // Create annotations
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "You"
        
        let stationCoord = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = stationCoord
        stationAnnotation.title = stationName
        
        uiView.addAnnotation(userAnnotation)
        uiView.addAnnotation(stationAnnotation)
        
        // Add polyline between the two points
        let polyline = MKPolyline(coordinates: [userLocation, stationCoord], count: 2)
        uiView.addOverlay(polyline)
        
        // Add circles (pulsing / decorative; same radius as before)
        let userCircle = MKCircle(center: userLocation, radius: 500)
        let stationCircle = MKCircle(center: stationCoord, radius: 500)
        uiView.addOverlay(userCircle)
        uiView.addOverlay(stationCircle)
        
        // Compute a region or visible rect that fits both annotations with padding
        let userPoint = MKMapPoint(userLocation)
        let stationPoint = MKMapPoint(stationCoord)
        let rect = MKMapRect(
            x: min(userPoint.x, stationPoint.x),
            y: min(userPoint.y, stationPoint.y),
            width: abs(userPoint.x - stationPoint.x),
            height: abs(userPoint.y - stationPoint.y)
        ).insetBy(dx: -2000, dy: -2000) // padding
        
        uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 220, right: 40), animated: true)
    }
    
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }
}

// MARK: - Coordinator

class MapCoordinator: NSObject, MKMapViewDelegate {
    // Annotation view for marker color / glyph
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // skip default blue dot for user location managed by map if map.showsUserLocation were true.
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "pin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            view?.annotation = annotation
        }
        
        if annotation.title ?? "" == "You" {
            view?.markerTintColor = UIColor.systemBlue
            view?.glyphImage = UIImage(systemName: "location.fill")
        } else {
            view?.markerTintColor = UIColor.systemTeal
            view?.glyphImage = UIImage(systemName: "mappin.circle.fill")
        }
        
        view?.canShowCallout = true
        return view
    }
    
    // Renderers for overlays (polyline + circles)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 3
            renderer.lineDashPattern = [6, 6]
            return renderer
        }
        
        if let circle = overlay as? MKCircle {
            let r = MKCircleRenderer(circle: circle)
            r.strokeColor = UIColor.systemBlue
            r.fillColor = UIColor.systemBlue.withAlphaComponent(0.12)
            r.lineWidth = 2
            return r
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

