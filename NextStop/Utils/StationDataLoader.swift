//
//  StationDataLoader.swift
//  NextStop
//
//  Created by Graeme Doherty on 08/12/2025.
//

import Foundation

func loadStations(from fileName: String, mode: TransportMode) -> [Station] {
    guard let url = Bundle.main.url(
        forResource: fileName,
        withExtension: "json"
    ) else {
        print("❌ Failed to find \(fileName).json")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([RawStation].self, from: data)

        return decoded.map {
            Station(
                lat: $0.lat,
                long: $0.long,
                destination: $0.destination,
                mode: mode
            )
        }
    } catch {
        print("❌ Error decoding \(fileName):", error)
        return []
    }
}
