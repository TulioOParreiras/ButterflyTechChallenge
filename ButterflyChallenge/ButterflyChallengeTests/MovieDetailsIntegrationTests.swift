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
    private var movieLoadCompletion: ((LoadResult) -> Void)?
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        movieLoadCompletion = completion
        requestedMovie = movie
    }
    
    func completeLoading(with movieDetails: MovieDetails) {
        movieLoadCompletion?(.success(movieDetails))
    }
    
    func completeLoadingWithFailure() {
        let error = NSError(domain: "", code: 0)
        movieLoadCompletion?(.failure(error))
    }
}

final class MovieDetailsIntegrationTests: XCTestCase {

    func test_viewLoad_requestLoadMovieDetails() throws {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let loader = MovieLoaderSpy()
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: loader)
        let view = MovieDetailsView(viewModel: viewModel)
        ViewHosting.host(view: view)
        XCTAssertEqual(movie, loader.requestedMovie, "Expected to request load details from movie assigned to View Model")
    }
    
    func test_loadingMovieIndicator_isVisibleWhileLoadingMovieDetails() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let loader = MovieLoaderSpy()
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: loader)
        let view = MovieDetailsView(viewModel: viewModel)
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: view)
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        loader.completeLoading(with: makeMovieDetails())
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expected to hide loading indicator when details are loaded with success")
    }
    
    func test_loadingMovieIndicator_isNotVisibleAfterDetailsLoadFailure() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let loader = MovieLoaderSpy()
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: loader)
        let view = MovieDetailsView(viewModel: viewModel)
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: view)
        XCTAssertTrue(view.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        loader.completeLoadingWithFailure()
        XCTAssertFalse(view.isShowingLoadingIndicator, "Expected to hide loading indicator when receiving a failure on details load")
    }
    
    // MARK: - Helpers
    
    func makeMovieDetails(
        id: String = "1",
        title: String = "A title",
        posterImageURL: URL? = nil,
        releaseDate: String = "A date",
        overview: String = "Movie overview",
        originalTitle: String = "The original title",
        duration: String = "Some duration"
    ) -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            posterImageURL: posterImageURL,
            releaseDate: releaseDate,
            overview: overview,
            originalTitle: originalTitle,
            duration: duration
        )
    }

}

extension MovieDetailsView {
    
    var isShowingLoadingIndicator: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.loading.rawValue)
        return view != nil
    }
    
}
