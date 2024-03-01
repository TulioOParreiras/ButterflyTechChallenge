//
//  MoviesListIntegrationTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import XCTest

@testable import ButterflyChallenge

class LoaderSpy: MoviesDataLoader {
    var moviesListRequests = [(url: URL, completion: (LoadResult) -> Void)]()
    var loadCallCount: Int { moviesListRequests.count }
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void) {
        moviesListRequests.append((url, completion))
    }
    
    func completeMoviesListLoading(at index: Int = 0) {
        moviesListRequests[index].completion(.success(Data()))
    }
}

final class MoviesListIntegrationTests: XCTestCase { 
    
    func test_loadMoviesActions_requestLoadMovies() {
        let loader = LoaderSpy()
        let sut = MoviesListViewController(moviesLoader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        sut.viewIsAppearing(false)
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingMoviesIndicator_isVisibleWhileLoadingMoviesList() {
        let loader = LoaderSpy()
        let sut = MoviesListViewController(moviesLoader: loader)

        sut.simulateAppearence()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading when view is loaded")
        
        loader.completeMoviesListLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading when movies list has completed loading")
    }
    
}
