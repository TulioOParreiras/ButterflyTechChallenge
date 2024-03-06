//
//  MovieDetailsView+PreviewHelpers.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

#if DEBUG
class MovieDetailsLoaderMock: MovieDetailsLoader {
    let result: LoadResult?
    
    init(result: LoadResult?) {
        self.result = result
    }
    
    struct TaskMock: DataLoaderTask {
        func cancel() { }
    }
    
    func loadMovieData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        if let result {
            completion(result)
        }
        return TaskMock()
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
            posterImageURL: URL(string: "https://any-url.com"),
            releaseDate: "A date",
            overview: "An overview",
            originalTitle: "A title",
            duration: "2h 30m"
        )
    }
}
#endif
