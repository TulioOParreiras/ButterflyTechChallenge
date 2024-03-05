//
//  MoviesListViewModel.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

final class MoviesListViewModel {
    typealias Observer<T> = (T) -> Void
    
    let moviesLoader: MoviesDataLoader
    let imageDataLoader: MovieImageDataLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onMoviesListLoad: Observer<[MovieCellController]>?
    var onMoviesListLoadError: Observer<String?>?
    
    private var searchTask: DataLoaderTask?
    private var controllersImageTasks = [MovieCellController: DataLoaderTask]()
    
    private var currentPage = 1
    
    enum Error: Swift.Error {
        case invalidImageData
    }
    
    init(moviesLoader: MoviesDataLoader, imageDataLoader: MovieImageDataLoader) {
        self.moviesLoader = moviesLoader
        self.imageDataLoader = imageDataLoader
    }
    
    func searchMovie(_ searchText: String) {
        guard
            let url = Endpoint.search(matching: searchText, page: String(describing: currentPage)).url
        else { return }
        onLoadingStateChange?(true)
        onMoviesListLoadError?(nil)
        searchTask?.cancel()
        searchTask = moviesLoader.loadMoviesData(from: url, completion: { [weak self] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.onMovieSearch(result) }
                return
            }
            self?.onMovieSearch(result)
        })
    }
    
    private func onMovieSearch(_ result: MoviesDataLoader.LoadResult) {
        searchTask = nil
        onLoadingStateChange?(false)
        do {
            let moviesList = try result.get()
            onMoviesListLoad?(moviesList.map { MovieCellController(model: $0, delegate: WeakRefVirtualProxy(self))} )
        } catch {
            onMoviesListLoadError?("Couldn't connect to server")
        }
    }
}

extension MoviesListViewModel: MovieCellControllerDelegate {
    func didRequestImage(for controller: MovieCellController) {
        guard
            let url = controller.model.posterImageURL
        else {
            controller.displayImage(.imagePlaceholder)
            return
        }
        controller.displayError(nil)
        controller.displayLoading(true)
        controllersImageTasks[controller]?.cancel()
        controllersImageTasks[controller] = imageDataLoader.loadImageData(from: url, completion: { [weak self, weak controller] result in
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self?.onImageLoad(result, controller: controller) }
                return
            }
            self?.onImageLoad(result, controller: controller)
        })
        
    }
    
    func didCancelImageRequest(for controller: MovieCellController) {
        controllersImageTasks[controller]?.cancel()
        controllersImageTasks[controller] = nil
    }
    
    private func onImageLoad(_ result: MovieImageDataLoader.LoadResult, controller: MovieCellController?) {
        controller?.displayLoading(false)
        do {
            let data = try result.get()
            let image = try mapImage(from: data)
            controller?.displayImage(image)
        } catch {
            controller?.displayError("Failed to get image")
        }
        if let controller { controllersImageTasks[controller] = nil }
    }
    
    private func mapImage(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw Error.invalidImageData
        }
        return image
    }
}

private extension UIImage {
    static var imagePlaceholder: UIImage? { UIImage(systemName: "photo") }
}
