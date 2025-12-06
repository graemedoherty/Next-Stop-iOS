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
    
    // Step 2 State
    @State private var searchText: String = ""
    @State private var selectedStation: Station? = nil
    
    // Step 3 State
    @State private var alarmIsSet: Bool = false
    
    // Mock station data (temporary)
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
        VStack(spacing: 24) {
            
            // Progress Indicator
            HStack {
                StepCircle(number: 1, isActive: step >= 1)
                Rectangle().frame(height: 3).opacity(step >= 2 ? 1 : 0.3)
                StepCircle(number: 2, isActive: step >= 2)
                Rectangle().frame(height: 3).opacity(step >= 3 ? 1 : 0.3)
                StepCircle(number: 3, isActive: step >= 3)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - STEP 1: Transport Selection
            if step == 1 {
                Text("Step 1")
                    .font(.headline)
                
                Text("Please select your mode of transport")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                ForEach(TransportMode.allCases) { mode in
                    Button(action: {
                        selectedMode = mode
                    }) {
                        HStack {
                            Text(mode.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedMode == mode ? Color.green : Color.gray, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal)
                }
                
                Button(action: {
                    step = 2
                }) {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMode == nil ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(selectedMode == nil)
            }
            
            // MARK: - STEP 2: Station Search
            if step == 2 {
                Text("Step 2")
                    .font(.headline)
                
                Text("Select your destination station")
                    .font(.title3)
                
                TextField("Type at least 3 letters...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if !filteredStations.isEmpty {
                    List(filteredStations) { station in
                        Button(action: {
                            selectedStation = station
                            searchText = station.name
                            step = 3
                        }) {
                            Text(station.name)
                        }
                    }
                    .frame(height: 200)
                }
                
                Button("Back") {
                    step = 1
                    searchText = ""
                }
                .padding(.top)
            }
            
            // MARK: - STEP 3: Set Alarm
            if step == 3 {
                Text("Step 3")
                    .font(.headline)
                
                if let station = selectedStation {
                    Text("Your destination:")
                    Text(station.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                }
                
                if !alarmIsSet {
                    Button(action: {
                        alarmIsSet = true
                        print("Alarm set for:", selectedStation?.name ?? "")
                    }) {
                        Text("Set Alarm")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Alarm is active ✅")
                            .font(.title3)
                        
                        Button("Cancel Alarm") {
                            alarmIsSet = false
                        }
                        .foregroundColor(.red)
                        .padding(.top)
                    }
                }
                
                Button("Back") {
                    step = 2
                    alarmIsSet = false
                }
                .padding(.top)
            }
            
            Spacer()
        }
    }
}

// MARK: - Step Circle UI Component

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

