//
//  MovieDetailsContentViewModel.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

enum MovieDetailsImageState {
    case loading
    case loaded(Data)
    case failure(Error)
    case empty
}

final class MovieDetailsContentViewModel: ObservableObject {
    
    @Published var imageState: MovieDetailsImageState = .empty
    
    let movieDetails: MovieDetails
    let imageLoader: MovieImageDataLoader
    
    private var imageLoadTask: DataLoaderTask?
    
    init(movieDetails: MovieDetails, imageLoader: MovieImageDataLoader) {
        self.movieDetails = movieDetails
        self.imageLoader = imageLoader
    }
    
    func onViewLoad() {
        loadMovieImage()
    }
    
    func onImageLoadRetry() {
        onViewLoad()
    }
    
    func onViewDisappear() {
        cancelCurrentLoadTask()
    }
    
    private func cancelCurrentLoadTask() {
        imageLoadTask?.cancel()
    }
    
    private func loadMovieImage() {
        guard let url = movieDetails.posterImageURL else { return }
        cancelCurrentLoadTask()
        imageState = .loading
        imageLoadTask = imageLoader.loadImageData(from: url, completion: { [weak self] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.onImageLoad(with: result) }
                return
            }
            self?.onImageLoad(with: result)
        })
    }
    
    private func onImageLoad(with result: MovieImageDataLoader.LoadResult) {
        do {
            let data = try result.get()
            imageState = .loaded(data)
        } catch {
            imageState = .failure(error)
        }
    }
    
}
