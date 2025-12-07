import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Transport Mode

enum TransportMode: String, CaseIterable, Identifiable {
    case train = "Train"
    case luas = "Luas"
    case bus = "Bus"
    
    var id: String { rawValue }
}

// MARK: - Models

struct Station: Identifiable {
    let id = UUID()
    let lat: String
    let long: String
    let destination: String
    let mode: TransportMode
}

struct RawStation: Decodable {
    let lat: String
    let long: String
    let destination: String
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}

// MARK: - Map View

struct MapViewRepresentable: UIViewRepresentable {
    let userLocation: CLLocationCoordinate2D
    let stationLat: Double
    let stationLong: Double
    let stationName: String
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        
        // Set black and white map style
        if #available(iOS 13.0, *) {
            map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .flat)
        }
        
        // User location annotation
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "You"
        map.addAnnotation(userAnnotation)
        
        // Station annotation
        let stationCoord = CLLocationCoordinate2D(latitude: stationLat, longitude: stationLong)
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = stationCoord
        stationAnnotation.title = stationName
        map.addAnnotation(stationAnnotation)
        
        // Calculate the center point between user and station
        let centerLat = (userLocation.latitude + stationLat) / 2
        let centerLong = (userLocation.longitude + stationLong) / 2
        
        // Calculate the distance to determine zoom level
        let latDelta = abs(userLocation.latitude - stationLat) * 1.5
        let longDelta = abs(userLocation.longitude - stationLong) * 1.5
        
        // Create region that fits both points with padding
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.01),
                longitudeDelta: max(longDelta, 0.01)
            )
        )
        map.setRegion(region, animated: true)
        
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Don't reset the region - just let the map display as set in makeUIView
    }
}

// MARK: - JSON Loader

func loadStations(from fileName: String, mode: TransportMode) -> [Station] {
    guard let url = Bundle.main.url(
        forResource: fileName,
        withExtension: "json"
    ) else {
        print("❌ Failed to find \(fileName).json")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([RawStation].self, from: data)

        return decoded.map {
            Station(
                lat: $0.lat,
                long: $0.long,
                destination: $0.destination,
                mode: mode
            )
        }
    } catch {
        print("❌ Error decoding \(fileName):", error)
        return []
    }
}

// MARK: - Main View

struct ContentView: View {
    @State private var selectedMode: TransportMode? = nil
    @State private var step: Int = 1
    
    @State private var searchText: String = ""
    @State private var selectedStation: Station? = nil
    @State private var alarmIsSet: Bool = false
    
    @StateObject private var locationManager = LocationManager()
    
    let allStations: [Station] = {
        let trains = loadStations(from: "trainData", mode: .train)
        let luas = loadStations(from: "luasData", mode: .luas)
        let buses = loadStations(from: "dublinbus", mode: .bus)
        return trains + luas + buses
    }()
    
    var filteredStations: [Station] {
        guard searchText.count >= 3, let mode = selectedMode else { return [] }
        return allStations.filter {
            $0.mode == mode &&
            $0.destination.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack {
            // Show map when alarm is active
            if alarmIsSet, let stationLat = Double(selectedStation?.lat ?? ""),
               let stationLong = Double(selectedStation?.long ?? "") {
                
                let testLocation = CLLocationCoordinate2D(latitude: 53.3498, longitude: -6.2603)
                
                MapViewRepresentable(
                    userLocation: testLocation,
                    stationLat: stationLat,
                    stationLong: stationLong,
                    stationName: selectedStation?.destination ?? ""
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            // Main UI when alarm is not active
            if !alarmIsSet {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Progress Indicator
                    HStack {
                        StepCircle(number: 1, isActive: step >= 1)
                        Rectangle().frame(height: 3).opacity(step >= 2 ? 1 : 0.3)
                        StepCircle(number: 2, isActive: step >= 2)
                        Rectangle().frame(height: 3).opacity(step >= 3 ? 1 : 0.3)
                        StepCircle(number: 3, isActive: step >= 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // STEP 1
                    if step == 1 {
                        Step1View(selectedMode: $selectedMode) {
                            step = 2
                        }
                    }
                    
                    // STEP 2
                    if step == 2 {
                        Step2View(
                            searchText: $searchText,
                            filteredStations: filteredStations
                        ) { station in
                            selectedStation = station
                            step = 3
                        } backAction: {
                            step = 1
                            searchText = ""
                        }
                    }
                    
                    // STEP 3
                    if step == 3 {
                        Step3View(
                            station: selectedStation,
                            alarmIsSet: $alarmIsSet,
                            backAction: {
                                step = 2
                                alarmIsSet = false
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
            
            // Bottom Alarm Card (only when alarm is set)
            if alarmIsSet, let station = selectedStation {
                AlarmBottomCard(
                    stationName: station.destination,
                    distance: "13.2 km",
                    cancelAction: {
                        alarmIsSet = false
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Step 1 View

struct Step1View: View {
    @Binding var selectedMode: TransportMode?
    var nextAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1: Select mode of transport").font(.headline).padding(.horizontal)
            
            ForEach(TransportMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    HStack {
                        Text(mode.rawValue).font(.headline)
                        Spacer()
                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).stroke(
                        selectedMode == mode ? Color.green : Color.gray, lineWidth: 2))
                }
                .padding(.horizontal)
            }
            
            Button("Next", action: nextAction)
                .disabled(selectedMode == nil)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedMode == nil ? Color.gray : Color.blue)
                .cornerRadius(14)
                .padding(.horizontal)
        }
    }
}

// MARK: - Step 2 View

struct Step2View: View {
    @Binding var searchText: String
    let filteredStations: [Station]
    var selectAction: (Station) -> Void
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 2: Select your destination ").font(.headline).padding(.horizontal)
            
            HStack {
                TextField("Type at least 3 letters...", text: $searchText)
                    .foregroundColor(.white)
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 14).stroke(Color.gray, lineWidth: 2))
            .padding(.horizontal)
            
            ForEach(filteredStations) { station in
                Button {
                    selectAction(station)
                } label: {
                    HStack {
                        Text(station.destination)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).stroke(Color.gray, lineWidth: 2))
                }
                .padding(.horizontal)
            }
            
            Button("Back", action: backAction)
                .padding(.horizontal)
        }
    }
}

// MARK: - Step 3 View

struct Step3View: View {
    let station: Station?
    @Binding var alarmIsSet: Bool
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 3: Set Alarm").font(.headline).padding(.horizontal)
            
            if !alarmIsSet {
                Button("Set Alarm") {
                    alarmIsSet = true
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(14)
                .padding(.horizontal)
            }
            
            Button("Back", action: backAction)
                .padding(.horizontal)
        }
    }
}

// MARK: - Bottom Alarm Card

struct AlarmBottomCard: View {
    let stationName: String
    let distance: String
    var cancelAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alarm Active").foregroundColor(.green).font(.caption)
                    Text(stationName).font(.headline)
                    Text("Distance: \(distance)").font(.subheadline).foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: cancelAction) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
        .frame(maxWidth: .infinity)
        .position(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height - 110
        )
    }
}

// MARK: - Step Circle

struct StepCircle: View {
    let number: Int
    let isActive: Bool
    
    var body: some View {
        Text("\(number)")
            .frame(width: 36, height: 36)
            .background(isActive ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(Circle())
    }
}

#Preview {
    ContentView()
}
