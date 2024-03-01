//
//  MoviesListIntegrationTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import XCTest

@testable import ButterflyChallenge

class LoaderSpy: MoviesDataLoader {
    var loadCallCount = 0
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void) {
        loadCallCount += 1
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
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to be loading \(sut.isShowingLoadingIndicator)")
    }
    
}
