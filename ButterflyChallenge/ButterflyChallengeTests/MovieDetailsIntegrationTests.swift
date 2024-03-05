//
//  MovieDetailsIntegrationTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import XCTest

import ViewInspector

@testable import ButterflyChallenge

class MovieLoaderSpy: MovieDetailsLoader {
    var requestedMovie: Movie?
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        requestedMovie = movie
    }
}

final class MovieDetailsIntegrationTests: XCTestCase {

    func test_viewLoad_requestLoadMovieDetails() throws {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let loader = MovieLoaderSpy()
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: loader)
        let view = MovieDetailsView(viewModel: viewModel)
        ViewHosting.host(view: view)
        XCTAssertEqual(movie, loader.requestedMovie)
    }

}
