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
        let (sut, loader) = makeSUT(movie: movie)
        ViewHosting.host(view: sut)
        XCTAssertEqual(movie, loader.requestedMovie, "Expected to request load details from movie assigned to View Model")
    }
    
    func test_loadingMovieIndicator_isVisibleWhileLoadingMovieDetails() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: sut)
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        loader.completeLoading(with: makeMovieDetails())
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading indicator when details are loaded with success")
    }
    
    func test_loadingMovieIndicator_isNotVisibleAfterDetailsLoadFailure() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: sut)
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        loader.completeLoadingWithFailure()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading indicator when receiving a failure on details load")
    }
    
    func test_loadMovieCompletion_rendersSuccesfullyLoadedMovieDetails() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertFalse(sut.isShowingMovieDetails, "Expected to not show movie details until view appears and finish loading details")
        
        ViewHosting.host(view: sut)
        XCTAssertFalse(sut.isShowingMovieDetails, "Expected to not show movie details until finish loading details")
        
        loader.completeLoading(with: makeMovieDetails())
        XCTAssertTrue(sut.isShowingMovieDetails, "Expected to show movie details when details are loaded with success")
    }
    
    // MARK: - Helpers
    
    func makeSUT(movie: Movie = .mock) -> (sut: MovieDetailsView, loader: MovieLoaderSpy) {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let loader = MovieLoaderSpy()
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: loader)
        let view = MovieDetailsView(viewModel: viewModel)
        return (view, loader)
    }
    
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
    
    var isShowingMovieDetails: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.movieDetails.rawValue)
        return view != nil
    }
    
}
