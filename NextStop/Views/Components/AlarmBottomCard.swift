//
//  AlarmBottomCard.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI

struct AlarmBottomCard: View {
    let stationName: String
    let distance: String
    var cancelAction: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alarm Active")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(stationName)
                        .font(.headline)
                    Text("Distance: \(distance)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
            y: UIScreen.main.bounds.height - 110
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

