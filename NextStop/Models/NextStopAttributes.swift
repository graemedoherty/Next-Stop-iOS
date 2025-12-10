//
//  NextStopAttributes.swift
//  NextStop
//
//  Created by ChatGPT on 2025-12-10.
//

import Foundation
import ActivityKit

public struct NextStopAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var distance: String    // e.g. "320 m"
        public var status: String      // e.g. "On the way" / "Arriving"

        public init(distance: String, status: String) {
            self.distance = distance
            self.status = status
        }
    }

    // fixed / non-changing attributes
    public var lineName: String         // "Train" / "Luas" / "Bus"
    public var destinationName: String  // e.g. "Connolly"

    public init(lineName: String, destinationName: String) {
        self.lineName = lineName
        self.destinationName = destinationName
    }
}

