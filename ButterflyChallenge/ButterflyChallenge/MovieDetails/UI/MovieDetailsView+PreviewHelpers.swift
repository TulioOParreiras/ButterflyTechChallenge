//
//  MovieDetailsView+PreviewHelpers.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

#if DEBUG
class MovieDetailsLoaderMock: MovieDetailsLoader {
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        completion(.success(.mock))
    }
}

extension Movie {
    static var mock: Movie {
        Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
    }
}

extension MovieDetails {
    static var mock: MovieDetails {
        MovieDetails(
            id: "1",
            title: "A title",
            posterImageURL: nil,
            releaseDate: "A date",
            overview: "An overview",
            originalTitle: "A title",
            duration: "2h 30m"
        )
    }
}
#endif
