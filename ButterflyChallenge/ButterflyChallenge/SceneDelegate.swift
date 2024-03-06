//
//  SceneDelegate.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: .shared)
    }()

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> UIViewController {
        let navigationController = UINavigationController()
        let moviesLoader = RemoteMoviesDataLoader(client: httpClient)
        let imageDataLoader = RemoteMovieImageDataLoader(client: httpClient)
        let moviesListController = MoviesListUIComposer.moviesListComposedWith(
            moviesLoader: moviesLoader,
            imagesLoader: imageDataLoader
        ) { [weak navigationController, weak self] movie in
            self?.onMovieSelection(movie, navigationController: navigationController)
        }
        navigationController.viewControllers = [moviesListController]
        return navigationController
    }
    
    private func onMovieSelection(_ movie: Movie, navigationController: UINavigationController?) {
        let movieDetailsLoader = RemoteMovieDetailsLoader(client: httpClient)
        let imageDataLoader = RemoteMovieImageDataLoader(client: httpClient)
        let view = MovieDetailsUIComposer.movieDetailsComposedWith(
            movie: movie,
            movieDetailsLoader: movieDetailsLoader,
            imageLoader: imageDataLoader
        )
        let hostingController = UIHostingController(rootView: view)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
}
