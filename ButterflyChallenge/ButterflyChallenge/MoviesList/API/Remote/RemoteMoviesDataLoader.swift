//
//  RemoteMoviesDataLoader.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

final class RemoteMoviesDataLoader: MoviesDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: DataLoaderTask {
        private var completion: ((MoviesDataLoader.LoadResult) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (MoviesDataLoader.LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: MoviesDataLoader.LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
            wrapped = nil
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data: Data, response: HTTPURLResponse) in
                    do {
                        let movies = try MovieListMapper.map(data, from: response)
                        return .success(movies)
                    } catch {
                        return .failure(error)
                    }
                }
            )
        }
        return task
    }
}
