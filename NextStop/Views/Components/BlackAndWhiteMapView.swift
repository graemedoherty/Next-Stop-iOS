import SwiftUI
import MapKit

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

