//
//  MovieDetailsLoader.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

protocol MovieDetailsLoader {
    typealias LoadResult = Result<MovieDetails, Error>
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void)
}
