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
    var requestsCallCount = 0
    var requestedMovie: Movie?
    private var movieLoadCompletion: ((LoadResult) -> Void)?
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        movieLoadCompletion = completion
        requestedMovie = movie
        requestsCallCount += 1
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

    func test_viewLoad_requestLoadMovieDetails() {
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
    
    func test_loadingMovieIndicator_isVisibleWhileRetryingToLoadMovieDetails() throws {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: sut)
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        loader.completeLoadingWithFailure()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading indicator when receiving a failure on details load")
        
        try sut.simulateRetryAction()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading indicator when tapping retry button")
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
    
    func test_loadMovieCompletion_rendersFailureViewOnError() {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertFalse(sut.isShowingFailure, "Expected to not show failure view when view is created")
        
        ViewHosting.host(view: sut)
        XCTAssertFalse(sut.isShowingFailure, "Expected to not show failure view when loading movie details")
        
        loader.completeLoadingWithFailure()
        XCTAssertTrue(sut.isShowingFailure, "Expected to show failure view when finish loading details with error")
    }
    
    func test_failureRetryAction_requestAnotherMovieDetailsLoad() throws {
        let movie = Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
        let (sut, loader) = makeSUT(movie: movie)
        XCTAssertEqual(loader.requestsCallCount, 0, "Expected to not request movie details until view is visible")
        
        ViewHosting.host(view: sut)
        XCTAssertEqual(loader.requestsCallCount, 1, "Expected to request movie details when view become visible")
        
        loader.completeLoadingWithFailure()
        try sut.simulateRetryAction()
        XCTAssertEqual(loader.requestsCallCount, 2, "Expected to attemp a new movie details request when tapping failure retry button")
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

import SwiftUI

extension MovieDetailsView {
    
    var isShowingLoadingIndicator: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.loading.rawValue)
        return view != nil
    }
    
    var isShowingMovieDetails: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.movieDetails.rawValue)
        return view != nil
    }
    
    var isShowingFailure: Bool {
        let view = try? failureView()
        return view != nil
    }
    
    func simulateRetryAction() throws {
        let view = try failureView()
        let button = try view.find(viewWithAccessibilityIdentifier: MovieDetailsFailureView.ViewIdentifiers.button.rawValue).button()
        try button.tap()
    }
    
    private func failureView() throws -> InspectableView<ViewType.ClassifiedView> {
        try inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.failureView.rawValue)
    }
    
}
