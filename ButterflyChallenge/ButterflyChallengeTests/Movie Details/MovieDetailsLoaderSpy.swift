//
//  MovieDetailsLoaderSpy.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

class MovieDetailsLoaderSpy: MovieDetailsLoader, MovieImageDataLoader {
    
    struct TaskSpy: DataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() { cancelCallback() }
    }
    
    // MARK: - MovieDetailsLoader
    
    var moviesDetailsRequests = [(url: URL, completion: (MovieDetailsLoader.LoadResult) -> Void)]()
    var requstedURLs: [URL] { moviesDetailsRequests.map { $0.url }}
    var loadCallCount: Int { moviesDetailsRequests.count }
    
    private(set) var cancelledMovieDetailsURLs = [URL]()
    
    func loadMovieData(from url: URL, completion: @escaping (MovieDetailsLoader.LoadResult) -> Void) -> DataLoaderTask {
        moviesDetailsRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledMovieDetailsURLs.append(url) }
    }
    
    func completeLoading(with movieDetails: MovieDetails, at index: Int = 0) {
        moviesDetailsRequests[index].completion(.success(movieDetails))
    }
    
    func completeLoadingWithFailure(at index: Int = 0) {
        let error = NSError(domain: "", code: 0)
        moviesDetailsRequests[index].completion(.failure(error))
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
