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
    
    @Published var viewState: MovieDetailsViewState = .empty
    
    let movie: Movie
    let movieDetailsLoader: MovieDetailsLoader
    
    private var movieLoadTask: DataLoaderTask?
    
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
    
    func onViewDisappear() {
        cancelCurrentLoadTask()
    }
    
    private func cancelCurrentLoadTask() {
        movieLoadTask?.cancel()
    }
    
    private func loadMovieDetails() {
        guard
            let url = Endpoint.movieDetails(movieId: movie.id).url
        else { return }
        viewState = .loading
        cancelCurrentLoadTask()
        movieLoadTask = movieDetailsLoader.loadMovieData(from: url, completion: { [weak self] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.onMovieDetailsLoad(result) }
                return
            }
            self?.onMovieDetailsLoad(result)
        })
    }
    
    private func onMovieDetailsLoad(_ result: MovieDetailsLoader.LoadResult) {
        do {
            let value = try result.get()
            viewState = .loaded(value)
        } catch {
            viewState = .failure(error)
        }
    }
}
