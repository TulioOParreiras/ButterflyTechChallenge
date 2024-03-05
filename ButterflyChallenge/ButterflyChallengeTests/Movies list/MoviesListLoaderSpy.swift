//
//  MoviesListLoaderSpy.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

class MoviesListLoaderSpy: MoviesDataLoader, MovieImageDataLoader {
    
    private struct TaskSpy: DataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() { cancelCallback() }
    }
    
    // MARK: - MoviesDataLoader
    
    var moviesListRequests = [(url: URL, completion: (MoviesDataLoader.LoadResult) -> Void)]()
    var loadCallCount: Int { moviesListRequests.count }
    
    private(set) var cancelledMoviesListURLs = [URL]()
    
    func loadMoviesData(from url: URL, completion: @escaping (MoviesDataLoader.LoadResult) -> Void) -> DataLoaderTask {
        moviesListRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledMoviesListURLs.append(url) }
    }
    
    func completeMoviesListLoading(with movies: [Movie] = [], at index: Int = 0) {
        moviesListRequests[index].completion(.success(movies))
    }
    
    func completeMoviesListLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        moviesListRequests[index].completion(.failure(error))
    }
    
    // MARK: - MovieImageDataLoader
    
    private var imageRequests = [(url: URL, completion: (MovieImageDataLoader.LoadResult) -> Void)]()
    
    var loadedImageURLs: [URL] {
        return imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (MovieImageDataLoader.LoadResult) -> Void) -> DataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
