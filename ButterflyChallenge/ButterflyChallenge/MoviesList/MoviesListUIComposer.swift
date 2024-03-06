//
//  MoviesListUIComposer.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

final class MoviesListUIComposer {
    private init() { }
    
    static func moviesListComposedWith(
        moviesLoader: MoviesDataLoader,
        imagesLoader: MovieImageDataLoader,
        onMovieSelection: @escaping (Movie) -> Void
    ) -> MoviesListViewController {
        let controller = makeMoviesListController()
        let viewModel = MoviesListViewModel(moviesLoader: moviesLoader, imageDataLoader: imagesLoader)
        controller.viewModel = viewModel
        controller.onMovieSelection = onMovieSelection
        return controller
    }
    
    private static func makeMoviesListController() -> MoviesListViewController {
        let bundle = Bundle(for: MoviesListViewController.self)
        let storyboard = UIStoryboard(name: "MoviesList", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! MoviesListViewController
        controller.title = "Movies List"
        return controller
    }
}
