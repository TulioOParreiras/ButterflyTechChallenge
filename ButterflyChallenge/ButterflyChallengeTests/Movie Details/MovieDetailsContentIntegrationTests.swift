//
//  MovieDetailsContentIntegrationTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import XCTest

import ViewInspector

@testable import ButterflyChallenge

final class MovieDetailsContentIntegrationTests: XCTestCase {

    func test_viewLoad_requestPosterImageLoad() {
        let movieDetails: MovieDetails = .mock
        let (sut, imageLoader) = makeSUT(movieDetails: movieDetails)
        XCTAssertEqual(imageLoader.loadedImageURLs, [], "Expected to not load image until view is visible")
        
        ViewHosting.host(view: sut)
        XCTAssertEqual(imageLoader.loadedImageURLs, [movieDetails.posterImageURL])
    }
    
    func test_loadingMovieImageIndicator_isVisibleWhileLoadingPosterImage() {
        let (sut, imageLoader) = makeSUT()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to not show loading indicator until view appears")
        
        ViewHosting.host(view: sut)
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show loading indicator once view appears")
        
        imageLoader.completeImageLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to hide loading indicator when details are loaded with success")
    }
    
    func test_imageLoadCompletion_rendersSuccessfullyLoadedImage() {
        let (sut, imageLoader) = makeSUT()
        ViewHosting.host(view: sut)
        XCTAssertNil(sut.renderedPosterImage)
        
        let data = UIImage.make(withColor: .red).pngData()
        imageLoader.completeImageLoading(with: data!)
        XCTAssertEqual(sut.renderedPosterImage, data, "Expected to render loaded image data")
    }
    
    // MARK: - Helpers
    
    func makeSUT(movieDetails: MovieDetails = .mock) -> (sut: MovieDetailsContentView, loader: MoviesListLoaderSpy) {
        let imageLoader = MoviesListLoaderSpy()
        let viewModel = MovieDetailsContentViewModel(movieDetails: movieDetails, imageLoader: imageLoader)
        let sut = MovieDetailsContentView(viewModel: viewModel)
        return (sut, imageLoader)
    }

}

extension MovieDetailsContentView {
    var isShowingLoadingIndicator: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: ViewIdentifiers.loadingIndicator.rawValue)
        return view != nil
    }
    
    var renderedPosterImage: Data? {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: ViewIdentifiers.posterImage.rawValue)
        let image = try? view?.image().actualImage().uiImage()
        return image?.pngData()
    }
}
