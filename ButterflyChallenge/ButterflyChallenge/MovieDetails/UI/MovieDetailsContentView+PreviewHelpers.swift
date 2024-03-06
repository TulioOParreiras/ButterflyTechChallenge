//
//  MovieDetailsContentView+PreviewHelpers.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

#if DEBUG
final class ImageLoaderMock: MovieImageDataLoader {
    let loadResult: LoadResult?
    
    init(loadResult: LoadResult?) {
        self.loadResult = loadResult
    }
    
    struct TaskMock: DataLoaderTask {
        func cancel() { }
    }
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        if let loadResult {
            completion(loadResult)
        }
        return TaskMock()
    }
}

extension MovieDetails {
    static var duneMovie: MovieDetails {
        MovieDetails(
            id: "1",
            title: "Dune",
            posterImageURL: URL(string: "https://any-url.com"),
            releaseDate: "2021",
            overview: "A noble family becomes embroiled in a war for control over the galaxy's most valuable asset while its heir becomes troubled by visions of a dark future",
            originalTitle: "Dune: Part One (original title)",
            duration: "2h 35m"
        )
    }
}
#endif
