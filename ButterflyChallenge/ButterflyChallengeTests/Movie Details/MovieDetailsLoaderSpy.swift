//
//  MovieDetailsLoaderSpy.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

class MovieDetailsLoaderSpy: MovieDetailsLoader {
    
    var moviesDetailsRequests = [(url: URL, completion: (MovieDetailsLoader.LoadResult) -> Void)]()
    var requstedURLs: [URL] { moviesDetailsRequests.map { $0.url }}
    var loadCallCount: Int { moviesDetailsRequests.count }
    
    private(set) var cancelledMovieDetailsURLs = [URL]()
    
    struct TaskSpy: DataLoaderTask {
        let cancelCallback: () -> Void
        func cancel() { cancelCallback() }
    }
    
    func loadMovieData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
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
}
