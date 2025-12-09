//
//  Step1View.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI

struct Step1View: View {
    @Binding var selectedMode: TransportMode?
    var nextAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 1: Select mode of transport")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(TransportMode.allCases) { mode in
                Button {
                    selectedMode = mode
                } label: {
                    HStack {
                        Text(mode.rawValue).font(.headline)
                        Spacer()
                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                selectedMode == mode ? Color.green : Color.gray,
                                lineWidth: 2
                            )
                    )
                }
                .disabled(mode == .bus)  // ✅ DISABLE BUS
                .opacity(mode == .bus ? 0.5 : 1)  // ✅ FADE IT OUT
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
