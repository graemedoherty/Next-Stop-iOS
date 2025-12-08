//
//  TransportMode.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import Foundation

enum TransportMode: String, CaseIterable, Identifiable {
    case train = "Train"
    case luas = "Luas"
    case bus = "Bus"
    
    var id: String { rawValue }
}

