//
//  MovieDetailsViewModel.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

enum MovieDetailsViewState {
    case loading
    case loaded(MovieDetails)
    case failure(Error)
    case empty
}

final class MovieDetailsViewModel: ObservableObject {
    let movie: Movie
    let movieDetailsLoader: MovieDetailsLoader
    
    @Published var viewState: MovieDetailsViewState = .empty
    
    init(movie: Movie, movieDetailsLoader: MovieDetailsLoader) {
        self.movie = movie
        self.movieDetailsLoader = movieDetailsLoader
    }
    
    func onViewLoad() {
        loadMovieDetails()
    }
    
    func onDetailsLoadRetry() {
        loadMovieDetails()
    }
    
    private func loadMovieDetails() {
        viewState = .loading
        movieDetailsLoader.loadMovieData(from: movie, completion: { [weak self] result in
            do {
                let value = try result.get()
                self?.viewState = .loaded(value)
            } catch {
                self?.viewState = .failure(error)
            }
        })
    }
}
