//
//  StepCircle.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//
import SwiftUI

struct StepCircle: View {
    let number: Int
    let isActive: Bool
    
    var body: some View {
        Text("\(number)")
            .frame(width: 36, height: 36)
            .background(isActive ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(Circle())
            .animation(.spring(), value: isActive)
    }
}

