//
//  StopActivityAttributes.swift
//  NextStop
//
//  Created by Graeme Doherty on 10/12/2025.
//


import ActivityKit

struct StopActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var stationName: String
        var distanceMeters: Int
    }

    var modeDisplayName: String
}

