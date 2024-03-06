//
//  ImageURLBuilderTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import XCTest

@testable import ButterflyChallenge

final class ImageURLBuilderTests: XCTestCase {

    func test_buildURL() {
        let imagePath = "an_image_path"
        let expectedURL = URL(string: "https://image.tmdb.org/t/p/w154/".appending(imagePath))
        XCTAssertEqual(ImageURLBuilder(path: imagePath).url, expectedURL)
    }

}
