import SwiftUI

enum TransportMode: String, CaseIterable, Identifiable {
    case train = "Train"
    case luas = "Luas"
    case bus = "Bus"
    
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var selectedMode: TransportMode? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Progress Indicator
            HStack {
                StepCircle(number: 1, isActive: true)
                Rectangle().frame(height: 3).opacity(0.3)
                StepCircle(number: 2, isActive: false)
                Rectangle().frame(height: 3).opacity(0.3)
                StepCircle(number: 3, isActive: false)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Step Title
            Text("Step 1")
                .font(.headline)
            
            Text("Please select your mode of transport")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            // Transport Buttons
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
            
            // Next Button
            Button(action: {
                print("Selected mode:", selectedMode?.rawValue ?? "")
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

