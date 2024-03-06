//
//  MovieDetailsUIComposer.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

final class MovieDetailsUIComposer {
    private init() { }
    
    static func movieDetailsComposedWith(movie: Movie, movieDetailsLoader: MovieDetailsLoader, imageLoader: MovieImageDataLoader) -> MovieDetailsView {
        let viewModel = MovieDetailsViewModel(movie: movie, movieDetailsLoader: movieDetailsLoader)
        let view = MovieDetailsView(viewModel: viewModel, imageLoader: imageLoader)
        return view
    }
}
