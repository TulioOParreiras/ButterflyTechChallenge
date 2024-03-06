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
        navigationController.viewControllers = [MoviesListUIComposer.moviesListComposedWith(
            moviesLoader: moviesLoader,
            imagesLoader: imageDataLoader
        ) { [weak navigationController, weak self] movie in
            guard let self else { return }
            let movieLoader = RemoteMovieDetailsLoader(client: self.httpClient)
            let view = MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie, movieDetailsLoader: movieLoader))
            let hostingController = UIHostingController(rootView: view)
            navigationController?.pushViewController(hostingController, animated: true)
        }]
        return navigationController
    }
    
}
