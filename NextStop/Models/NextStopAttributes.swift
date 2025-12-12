import ActivityKit

struct NextStopAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var distance: String
        var hasArrived: Bool = false   // ← ADD THIS
    }

    var destinationName: String
}

