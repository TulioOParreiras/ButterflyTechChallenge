//
//  MoviesListIntegrationTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import XCTest

@testable import ButterflyChallenge

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
    
    func test_loadMoviesActions_cancelPreviousLoadRequests() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(loader.cancelledMoviesListURLs.isEmpty, "Expected no cancelled movie search URL requests until two searches are requested")
        
        sut.simulateSearchForText("A")
        XCTAssertTrue(loader.cancelledMoviesListURLs.isEmpty, "Expected no cancelled movie search URL requests until two searches are requested")
        
        sut.simulateSearchForText("Ab")
        XCTAssertEqual(loader.cancelledMoviesListURLs.count, 1, "Expected one cancelled movie search URL request once first request was not finished and a new search has been made")
        
        sut.simulateSearchForText("Abc")
        XCTAssertEqual(loader.cancelledMoviesListURLs.count, 2, "Expected two cancelled movie search URL request since first and second requests were not finished and a new search has been made")
        
        loader.completeMoviesListLoading()
        sut.simulateSearchForText("Abcd")
        XCTAssertEqual(loader.cancelledMoviesListURLs.count, 2, "Expected two cancelled movie search URL request since previous request has been finished before a new one has been requested")
    }
    
    func test_loadingMoviesIndicator_isVisibleWhileLoadingMoviesList() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThatSUTIsNotRenderingShimmeringCells(sut)
        
        sut.simulateSearchForText("A movie")
        assertThatSUTIsRenderingShimmeringCells(sut)
        
        loader.completeMoviesListLoading()
        assertThatSUTIsNotRenderingShimmeringCells(sut)
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedMovies() {
        let movie0 = makeMovie(title: "A movie", releaseDate: "A release date")
        let movie1 = makeMovie(title: "Another movie", releaseDate: "Another release date")
        let movie2 = makeMovie(title: "A new movie", releaseDate: "A new release date")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        sut.simulateSearchForText("A movie")
        assertThatSUTIsRenderingShimmeringCells(sut)
        
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
        loader.completeMoviesListLoadingWithError(at: 1)
        assertThat(sut, isRendering: [movie0])
    }
    
    func test_loadMoviesCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        sut.simulateSearchForText("A movie")
        loader.completeMoviesListLoadingWithError()
        XCTAssertEqual(sut.errorMessage, "Couldn't connect to server")
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_movieCell_loadsImageURLWhenVisible() {
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [movie0, movie1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_movieCell_cancelsImageLoadingWhenNotVisibleAnymore() {
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [movie0, movie1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateMovieCellNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.posterImageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateMovieCellNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_movieCellLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie(), makeMovie()])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_movieCell_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie(), makeMovie()])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(view0?.renderedPosterImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedPosterImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedPosterImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedPosterImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedPosterImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedPosterImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_movieCellRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie(), makeMovie()])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_movieCellRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie()])
        
        let view = sut.simulateMovieCellVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_movieCellRetryAction_retriesImageLoad() {
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [movie0, movie1])
        
        let view0 = sut.simulateMovieCellVisible(at: 0)
        let view1 = sut.simulateMovieCellVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL, movie0.posterImageURL,], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL, movie0.posterImageURL, movie1.posterImageURL], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_movieCell_preloadsImageURLWhenNearVisible() {
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [movie0, movie1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateMovieCellNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateMovieCellNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected second image URL request once second image is near visible")
    }
    
    func test_movieCell_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [movie0, movie1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateMovieCellNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.posterImageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateMovieCellNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_movieCell_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie()])

        let view = sut.simulateMovieCellNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedPosterImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_movieCellSelection_triggerAction() {
        var selectedMovie: Movie?
        let (sut, loader) = makeSUT { selectedMovie = $0 }
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        let movie0 = makeMovie(posterImageURL: URL(string: "http://url-0.com")!)
        let movie1 = makeMovie(posterImageURL: URL(string: "http://url-1.com")!)
        loader.completeMoviesListLoading(with: [movie0, movie1])
        
        sut.simulateCellSelection(at: 0)
        XCTAssertEqual(selectedMovie, movie0, "Expected selected movie to be \(movie0) when selecting row 0, got \(String(describing: selectedMovie)) instead")
        
        sut.simulateCellSelection(at: 1)
        XCTAssertEqual(selectedMovie, movie1, "Expected selected movie to be \(movie1) when selecting row 1, got \(String(describing: selectedMovie)) instead")
    }
    
    func test_loadingCellSelection_doesNotTriggerAction() {
        var selectedMovie: Movie?
        let (sut, _) = makeSUT { selectedMovie = $0 }
        
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        XCTAssertNil(selectedMovie, "Expected selected movie to be nil when not tapping any cell")
        
        sut.simulateCellSelection(at: 0)
        XCTAssertNil(selectedMovie, "Expected selected movie to be nil when tapping first shimmering cell")
        
        sut.simulateCellSelection(at: 1)
        XCTAssertNil(selectedMovie, "Expected selected movie to be nil when tapping second shimmering cell")
        
        sut.simulateCellSelection(at: 2)
        XCTAssertNil(selectedMovie, "Expected selected movie to be nil when tapping third shimmering cell")
    }
    
    func test_loadMoviesCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeMoviesListLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.simulateSearchForText("A")
        loader.completeMoviesListLoading(with: [makeMovie()])
        _ = sut.simulateMovieCellVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    func makeSUT(
        onMovieSelection: @escaping (Movie) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: MoviesListViewController, loader: MoviesListLoaderSpy) {
        let loader = MoviesListLoaderSpy()
        let sut = MoviesListUIComposer.moviesListComposedWith(
            moviesLoader: loader,
            imagesLoader: loader,
            onMovieSelection: onMovieSelection
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
}
