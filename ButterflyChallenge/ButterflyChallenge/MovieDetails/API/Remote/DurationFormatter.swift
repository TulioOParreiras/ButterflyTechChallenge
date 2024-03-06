//
//  DurationFormatter.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

struct DurationFormatter {
    private let durationInMinutes: Int?
    
    init(durationInMinutes: Int?) {
        self.durationInMinutes = durationInMinutes
    }
    
    func formattedDuration(units: NSCalendar.Unit = [.hour, .minute]) -> String? {
        guard let durationInMinutes else { return nil }
        let durationInSeconds = durationInMinutes * 60
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .brief
        return formatter.string(from: TimeInterval(durationInSeconds))?.replacingOccurrences(of: ".", with: "")
    }
}
