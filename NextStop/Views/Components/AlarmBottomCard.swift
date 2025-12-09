//
//  AlarmBottomCard.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI

struct AlarmBottomCard: View {
    let stationName: String
    let distanceMeters: Double
    var cancelAction: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ✅ TOP ROW: Alarm Active + X Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alarm Active")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Spacer()
                
                Button(action: cancelAction) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            .padding(.bottom, 1)
            
            // ✅ LARGE DISTANCE DISPLAY
            VStack(alignment: .leading, spacing: 4) {
                Text("Distance")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(String(format: "%.0f", distanceMeters))m")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundColor(.green)
            }
            
            // ✅ STATION INFO
            VStack(alignment: .leading, spacing: 4) {
                Text("Station")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(stationName)
                    .font(.headline)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(isAnimating ? 0.8 : 0.3),
                            Color.green.opacity(isAnimating ? 0.3 : 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.green.opacity(0.3), radius: 10)
        .padding()
        .frame(maxWidth: .infinity)
        .position(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height - 200 // ✅ Moved up slightly for more visible space
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
