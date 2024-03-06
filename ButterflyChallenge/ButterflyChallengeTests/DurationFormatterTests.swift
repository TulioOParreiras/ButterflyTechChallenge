//
//  DurationFormatterTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import XCTest

@testable import ButterflyChallenge

final class DurationFormatterTests: XCTestCase {
    
    func test_format_oneHourAndHalf() {
        let oneHourAndHalf = Int(60 * 1.5)
        let expectedDuration = "1hr 30min"
        XCTAssertEqual(expectedDuration ,DurationFormatter(durationInMinutes: oneHourAndHalf).formattedDuration())
    }
    
    func test_format_twoHoursAndFifteenMinutes() {
        let twoHoursAndFifteenMinutes = Int(60 * 2.25)
        let expectedDuration = "2hrs 15min"
        XCTAssertEqual(expectedDuration ,DurationFormatter(durationInMinutes: twoHoursAndFifteenMinutes).formattedDuration())
    }
    
    func test_format_oneHour() {
        let oneHour = Int(60)
        let expectedDuration = "1hr"
        XCTAssertEqual(expectedDuration ,DurationFormatter(durationInMinutes: oneHour).formattedDuration())
    }
    
    func test_format_halfHour() {
        let halfHour = Int(30)
        let expectedDuration = "30min"
        XCTAssertEqual(expectedDuration ,DurationFormatter(durationInMinutes: halfHour).formattedDuration())
    }
    
}
