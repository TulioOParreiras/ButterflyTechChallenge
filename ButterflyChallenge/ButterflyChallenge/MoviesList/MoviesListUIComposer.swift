//
//  MoviesListUIComposer.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

final class MoviesListUIComposer {
    static func moviesListComposedWith(moviesLoader: MoviesDataLoader, imagesLoader: MovieImageDataLoader) -> MoviesListViewController {
        let controller = makeMoviesListController()
        controller.moviesLoader = moviesLoader
        controller.imageDataLoader = imagesLoader
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
