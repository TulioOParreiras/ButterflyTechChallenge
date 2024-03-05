//
//  MovieDetailsLoaderSpy.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

class MovieDetailsLoaderSpy: MovieDetailsLoader {
    var requestsCallCount = 0
    var requestedMovie: Movie?
    private var movieLoadCompletion: ((LoadResult) -> Void)?
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        movieLoadCompletion = completion
        requestedMovie = movie
        requestsCallCount += 1
    }
    
    func completeLoading(with movieDetails: MovieDetails) {
        movieLoadCompletion?(.success(movieDetails))
    }
    
    func completeLoadingWithFailure() {
        let error = NSError(domain: "", code: 0)
        movieLoadCompletion?(.failure(error))
    }
}
