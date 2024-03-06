//
//  MovieListMapperTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import XCTest

@testable import ButterflyChallenge

final class MovieListMapperTests: XCTestCase {
    
    func test_mapMovie() throws {
        let posterPath = "an_image_path"
        let expectedMovies = [
            Movie(
                id: "1",
                title: "A title",
                posterImageURL: ImageURLBuilder(path: posterPath).url,
                releaseDate: "2023"
            )
        ]
        let movieData = [
            "results": [
                [
                    "id": 1,
                    "title": "A title",
                    "poster_path": posterPath,
                    "release_date": "2023-01-01"
                ]
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: movieData)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://any-url.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        XCTAssertEqual(expectedMovies, try MovieListMapper.map(data, from: urlResponse))
    }
    
    func test_mapMovie_withMissingPoster() throws {
        let expectedMovies = [
            Movie(
                id: "1",
                title: "A title",
                posterImageURL: nil,
                releaseDate: "2023"
            )
        ]
        let movieData = [
            "results": [
                [
                    "id": 1,
                    "title": "A title",
                    "poster_path": nil,
                    "release_date": "2023-01-01"
                ]
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: movieData)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://any-url.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        XCTAssertEqual(expectedMovies, try MovieListMapper.map(data, from: urlResponse))
    }

}

