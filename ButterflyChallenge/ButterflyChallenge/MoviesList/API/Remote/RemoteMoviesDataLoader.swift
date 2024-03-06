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
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        let task = HTTPClientTaskWrapper<LoadResult>(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
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
