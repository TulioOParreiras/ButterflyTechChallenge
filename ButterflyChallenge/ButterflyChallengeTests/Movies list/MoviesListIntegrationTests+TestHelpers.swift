//
//  MoviesListIntegrationTests+TestHelpers.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import XCTest

@testable import ButterflyChallenge

extension Movie: Equatable {
    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}

extension MoviesListIntegrationTests {
    
    func assertThat(
        _ sut: MoviesListViewController,
        isRendering moviesList: [Movie],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedCells() == moviesList.count else {
            return XCTFail("Expected \(moviesList.count) movies, got \(sut.numberOfRenderedCells()) instead.", file: file, line: line)
        }
        
        moviesList.enumerated().forEach { index, movie in
            assertThat(sut, hasViewConfiguredFor: movie, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: MoviesListViewController, hasViewConfiguredFor movie: Movie, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.cell(at: index)
        
        guard let cell = view as? MovieViewCell else {
            return XCTFail("Expected \(MovieViewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, movie.title, "Expected movie title to be \(String(describing: movie.title)) for movie cell at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.releaseDateText, movie.releaseDate, "Expected release date text to be \(String(describing: movie.releaseDate)) for movie cell at index (\(index)", file: file, line: line)
    }
    
    func assertThatSUTIsRenderingShimmeringCells(_ sut: MoviesListViewController, file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
     
        guard sut.numberOfRenderedCells() == sut.numberOfShimmeringCells else {
            return XCTFail("Expected \(sut.numberOfShimmeringCells) shimmering cells, got \(sut.numberOfRenderedCells()) instead.", file: file, line: line)
        }
        
        (0 ..< sut.numberOfShimmeringCells).forEach { index in
            let view = sut.cell(at: index)
            guard let cell = view as? MovieShimmeringCell else {
                return XCTFail("Expected \(String(describing: MovieShimmeringCell.self)) at \(index), got \(String(describing: view)) instead", file: file, line: line)
            }
            XCTAssertTrue(cell.isShimmeringImage, "Expected to have image container shimmering", file: file, line: line)
            XCTAssertTrue(cell.isShimmeringTitle, "Expected to have title container shimmering", file: file, line: line)
            XCTAssertTrue(cell.isShimmeringDate, "Expected to have date container shimmering", file: file, line: line)
        }
    }
    
    func assertThatSUTIsNotRenderingShimmeringCells(_ sut: MoviesListViewController, file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedCells() == 0 else {
            return XCTFail("Expected to have no rendered cell, got \(sut.numberOfRenderedCells()) instead", file: file, line: line)
        }
    }
    
    func makeMovie(
        title: String = "A title",
        posterImageURL: URL = URL(string: "https://any-url.com")!,
        releaseDate: String = "Today"
    ) -> Movie {
        Movie(id: UUID().uuidString, title: title, posterImageURL: posterImageURL, releaseDate: releaseDate)
    }
    
}
