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
        let (sut, loader) = makeSUT()
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
        let (sut, loader) = makeSUT()

        sut.simulateAppearence()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading when view is loaded")
        
        loader.completeMoviesListLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading when movies list has completed loading")
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: MoviesListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = MoviesListViewController(moviesLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
}

extension XCTestCase {
    
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "\(String(describing: object)) was expected to be removed from memory, possible retain cycle", file: file, line: line)
        }
    }
    
}
