//
//  Step3View.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import SwiftUI

struct Step3View: View {
    let station: Station?
    @Binding var alarmIsSet: Bool
    var backAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step 3: Set Alarm")
                .font(.headline)
                .padding(.horizontal)
            
            if !alarmIsSet {
                Button("Set Alarm") {
                    withAnimation(.spring()) {
                        alarmIsSet = true
                    }
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

