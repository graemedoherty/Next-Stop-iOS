import SwiftUI

// MARK: - Models

enum TransportMode: String, CaseIterable, Identifiable {
    case train = "Train"
    case luas = "Luas"
    case bus = "Bus"
    
    var id: String { rawValue }
}

struct Station: Identifiable {
    let id = UUID()
    let name: String
    let mode: TransportMode
}

// MARK: - Main View

struct ContentView: View {
    @State private var selectedMode: TransportMode? = nil
    @State private var step: Int = 1
    
    @State private var searchText: String = ""
    @State private var selectedStation: Station? = nil
    @State private var alarmIsSet: Bool = false
    
    // Mock station data
    let mockStations: [Station] = [
        Station(name: "Heuston", mode: .train),
        Station(name: "Connolly", mode: .train),
        Station(name: "Pearse", mode: .train),
        Station(name: "Tallaght", mode: .luas),
        Station(name: "Sandyford", mode: .luas),
        Station(name: "O'Connell Street", mode: .bus),
        Station(name: "Stillorgan", mode: .bus)
    ]
    
    var filteredStations: [Station] {
        guard searchText.count >= 3, let mode = selectedMode else { return [] }
        return mockStations.filter {
            $0.mode == mode &&
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack {
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
                
                // MARK: - STEP 1
                if step == 1 {
                    Step1View(selectedMode: $selectedMode) {
                        step = 2
                    }
                }
                
                // MARK: - STEP 2
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
                
                // MARK: - STEP 3
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
            
            // ✅ Bottom Alarm Card
            if alarmIsSet, let station = selectedStation {
                AlarmBottomCard(
                    stationName: station.name,
                    distance: "1.2 km", // ✅ Dummy for now
                    cancelAction: {
                        alarmIsSet = false
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - STEP 1 VIEW

struct Step1View: View {
    @Binding var selectedMode: TransportMode?
    var nextAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1").font(.headline).padding(.horizontal)
            Text("Please select your mode of transport").font(.title3).padding(.horizontal)
            
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

// MARK: - STEP 2 VIEW

struct Step2View: View {
    @Binding var searchText: String
    let filteredStations: [Station]
    var selectAction: (Station) -> Void
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 2").font(.headline).padding(.horizontal)
            Text("Select your destination station").font(.title3).padding(.horizontal)
            
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
                        Text(station.name)
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

// MARK: - STEP 3 VIEW

struct Step3View: View {
    let station: Station?
    @Binding var alarmIsSet: Bool
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 3").font(.headline).padding(.horizontal)
            
            if let station = station {
                Text("Your destination:").padding(.horizontal)
                Text(station.name).font(.title2).bold().padding(.horizontal)
            }
            
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
                VStack(alignment: .leading, spacing: 4) {
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
        .position(x: UIScreen.main.bounds.width / 2,
                  y: UIScreen.main.bounds.height - 100)
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

