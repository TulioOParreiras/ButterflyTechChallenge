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
    
    func completeMoviesListLoading(with movies: [Movie] = [], at index: Int = 0) {
        moviesListRequests[index].completion(.success(movies))
    }
    
    func completeMoviesListLoadingWithError(_ error: Error, at index: Int = 0) {
        moviesListRequests[index].completion(.failure(error))
    }
}

final class MoviesListIntegrationTests: XCTestCase { 
    
    func test_loadMoviesActions_requestLoadMovies() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected to not load movies list on view load")
        
        sut.simulateSearchForText("A movie")
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to load movies list on search")
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected to refresh movies list on pull down to refresh")
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected another refresh request on another pull down to refresh")
    }
    
    func test_loadingMoviesIndicator_isVisibleWhileLoadingMoviesList() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearence()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to not show loading when view is loaded")
        
        sut.simulateSearchForText("A movie")
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading when searching for a movie")
        
        loader.completeMoviesListLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading when movies list has completed loading")
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedMovies() {
        let movie0 = makeMovie(title: "A movie", releaseDate: "A release date")
        let movie1 = makeMovie(title: "Another movie", releaseDate: "Another release date")
        let movie2 = makeMovie(title: "A new movie", releaseDate: "A new release date")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        sut.simulateSearchForText("A movie")
        assertThat(sut, isRendering: [])
        
        loader.completeMoviesListLoading(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateSearchForText("another movie")
        
        loader.completeMoviesListLoading(with: [movie0, movie1, movie2], at: 1)
        assertThat(sut, isRendering: [movie0, movie1, movie2])
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedEmptyMoviesAfterNonEmptyMovies() {
        let movie0 = makeMovie()
        let movie1 = makeMovie()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        sut.simulateSearchForText("A movie")
        loader.completeMoviesListLoading(with: [movie0, movie1], at: 0)
        assertThat(sut, isRendering: [movie0, movie1])

        sut.simulateSearchForText("Another movie")
        loader.completeMoviesListLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadMoviesCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let movie0 = makeMovie()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.simulateSearchForText("A movie")
        loader.completeMoviesListLoading(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateUserInitiatedMoviesListReload()
        loader.completeMoviesListLoadingWithError(anyError(), at: 1)
        assertThat(sut, isRendering: [movie0])
    }
    
    func test_loadMoviesCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        sut.simulateSearchForText("A movie")
        loader.completeMoviesListLoadingWithError(anyError())
        XCTAssertEqual(sut.errorMessage, "Couldn't connect to server")
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: MoviesListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = MoviesListViewController(moviesLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(
        _ sut: MoviesListViewController,
        isRendering moviesList: [Movie],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedMovies() == moviesList.count else {
            return XCTFail("Expected \(moviesList.count) movies, got \(sut.numberOfRenderedMovies()) instead.", file: file, line: line)
        }
        
        moviesList.enumerated().forEach { index, movie in
            assertThat(sut, hasViewConfiguredFor: movie, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: MoviesListViewController, hasViewConfiguredFor movie: Movie, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.movieView(at: index)
        
        guard let cell = view as? MovieViewCell else {
            return XCTFail("Expected \(MovieViewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, movie.title, "Expected movie title to be \(String(describing: movie.title)) for movie cell at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.releaseDateText, movie.releaseDate, "Expected release date text to be \(String(describing: movie.releaseDate)) for movie cell at index (\(index)", file: file, line: line)
    }
    
    private func makeMovie(
        title: String = "A title",
        posterImageURL: URL = URL(string: "https://any-url.com")!,
        releaseDate: String = "Today"
    ) -> Movie {
        Movie(id: UUID().uuidString, title: title, posterImageURL: posterImageURL, releaseDate: releaseDate)
    }
    
}

extension XCTestCase {
    func anyError() -> Error {
        NSError(domain: "an error", code: 0)
    }
}
