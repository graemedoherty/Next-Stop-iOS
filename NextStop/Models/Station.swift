//
//  Station.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import Foundation

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

