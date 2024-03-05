//
//  MovieImageDataLoader.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

public protocol DataLoaderTask {
    func cancel()
}

public protocol MovieImageDataLoader {
    typealias LoadResult = Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask
}

protocol MoviesDataLoader {
    typealias LoadResult = Result<[Movie], Error>
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask
}
