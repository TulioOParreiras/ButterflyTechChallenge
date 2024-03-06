//
//  RemoteMovieDetailsLoader.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

final class RemoteMovieDetailsLoader: MovieDetailsLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func loadMovieData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        let task = HTTPClientTaskWrapper<LoadResult>(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data: Data, response: HTTPURLResponse) in
                    do {
                        let movieDetails = try MovieDetailsMapper.map(data, from: response)
                        return .success(movieDetails)
                    } catch {
                        return .failure(error)
                    }
                }
            )
        }
        return task
    }
}
