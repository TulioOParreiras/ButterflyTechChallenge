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
    
    private var imageTask: DataLoaderTask?
    
    init(movieDetails: MovieDetails, imageLoader: MovieImageDataLoader) {
        self.movieDetails = movieDetails
        self.imageLoader = imageLoader
    }
    
    func onViewLoad() {
        guard let url = movieDetails.posterImageURL else { return }
        imageTask?.cancel()
        imageState = .loading
        imageTask = imageLoader.loadImageData(from: url, completion: { [weak self] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.onImageLoad(with: result) }
                return
            }
            self?.onImageLoad(with: result)
        })
    }
    
    func onImageLoadRetry() {
        onViewLoad()
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
