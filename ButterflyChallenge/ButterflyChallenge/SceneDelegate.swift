//
//  SceneDelegate.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> UIViewController {
        let navigationController = UINavigationController()
        let client = URLSessionHTTPClient(session: .shared)
        let moviesLoader = RemoteMoviesDataLoader(client: client)
        let imageDataLoader = RemoteMovieImageDataLoader(client: client)
        navigationController.viewControllers = [MoviesListUIComposer.moviesListComposedWith(
            moviesLoader: moviesLoader,
            imagesLoader: imageDataLoader
        ) { [weak navigationController] movie in
            let view = MovieDetailsView()
            let hostingController = UIHostingController(rootView: view)
            navigationController?.pushViewController(hostingController, animated: true)
        }]
        return navigationController
    }
    
}
