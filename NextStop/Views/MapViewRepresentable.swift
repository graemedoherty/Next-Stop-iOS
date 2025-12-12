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

        // Create persistent annotations
        let userAnn = MKPointAnnotation()
        userAnn.title = "You"
        context.coordinator.userAnnotation = userAnn

        let stationAnn = MKPointAnnotation()
        stationAnn.title = stationName
        context.coordinator.stationAnnotation = stationAnn

        map.addAnnotations([userAnn, stationAnn])

        // Create persistent polyline + circles
        context.coordinator.userCircle = MKCircle(center: userLocation, radius: 500)
        context.coordinator.stationCircle = MKCircle(center: CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong), radius: 500)

        map.addOverlay(context.coordinator.userCircle!)
        map.addOverlay(context.coordinator.stationCircle!)

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        DispatchQueue.main.async {

            // Update annotation positions
            context.coordinator.userAnnotation?.coordinate = userLocation
            context.coordinator.stationAnnotation?.coordinate = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)

            // Update circles
            if let userCircle = context.coordinator.userCircle {
                uiView.removeOverlay(userCircle)
            }
            context.coordinator.userCircle = MKCircle(center: userLocation, radius: 500)
            uiView.addOverlay(context.coordinator.userCircle!)

            if let stationCircle = context.coordinator.stationCircle {
                uiView.removeOverlay(stationCircle)
            }
            context.coordinator.stationCircle = MKCircle(center: CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong), radius: 500)
            uiView.addOverlay(context.coordinator.stationCircle!)

            // Update polyline
            if let existing = context.coordinator.polyline {
                uiView.removeOverlay(existing)
            }
            let newLine = MKPolyline(coordinates: [userLocation,
                                                   CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)], count: 2)
            context.coordinator.polyline = newLine
            uiView.addOverlay(newLine)

            // Camera region (no animation—prevents Metal crash)
            let userPoint = MKMapPoint(userLocation)
            let stationPoint = MKMapPoint(CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong))
            let rect = MKMapRect(
                x: min(userPoint.x, stationPoint.x),
                y: min(userPoint.y, stationPoint.y),
                width: abs(userPoint.x - stationPoint.x),
                height: abs(userPoint.y - stationPoint.y)
            ).insetBy(dx: -2000, dy: -2000)

            uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 220, right: 40), animated: false)
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }

    func dismantleUIView(_ uiView: MKMapView, coordinator: MapCoordinator) {
        uiView.delegate = nil
        uiView.layer.removeAllAnimations()
        uiView.removeFromSuperview()
    }
}

// MARK: - Coordinator

class MapCoordinator: NSObject, MKMapViewDelegate {
    var userAnnotation: MKPointAnnotation?
    var stationAnnotation: MKPointAnnotation?

    var polyline: MKPolyline?
    var userCircle: MKCircle?
    var stationCircle: MKCircle?

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let id = "pin"
        let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView)
            ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)

        if annotation.title == "You" {
            view.markerTintColor = .systemBlue
            view.glyphImage = UIImage(systemName: "location.fill")
        } else {
            view.markerTintColor = .systemTeal
            view.glyphImage = UIImage(systemName: "mappin.circle.fill")
        }

        view.canShowCallout = true
        view.annotation = annotation
        return view
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let line = overlay as? MKPolyline {
            let r = MKPolylineRenderer(polyline: line)
            r.strokeColor = .systemBlue
            r.lineWidth = 3
            r.lineDashPattern = [6, 6]
            return r
        }

        if let circle = overlay as? MKCircle {
            let r = MKCircleRenderer(circle: circle)
            r.strokeColor = .systemBlue
            r.fillColor = UIColor.systemBlue.withAlphaComponent(0.12)
            r.lineWidth = 2
            return r
        }

        return MKOverlayRenderer(overlay: overlay)
    }
}
