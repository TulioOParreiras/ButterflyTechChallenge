//
//  RemoteMovieImageDataLoader.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

final class RemoteMovieImageDataLoader: MovieImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: DataLoaderTask {
        private var completion: ((MovieImageDataLoader.LoadResult) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (MovieImageDataLoader.LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: MovieImageDataLoader.LoadResult) {
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
    
    public func loadImageData(from url: URL, completion: @escaping (MovieImageDataLoader.LoadResult) -> Void) -> DataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        return task
    }
}

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
