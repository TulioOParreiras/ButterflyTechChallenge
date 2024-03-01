//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

protocol MoviesDataLoader {
    typealias LoadResult = Swift.Result<Data, Error>
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void)
}

final class MoviesListViewController: UITableViewController {
    let moviesLoader: MoviesDataLoader
    
    init(moviesLoader: MoviesDataLoader) {
        self.moviesLoader = moviesLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        refresh()
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        guard let url = URL(string: "https://any-url.com") else { return }
        refreshControl?.beginRefreshing()
        moviesLoader.loadMoviesData(from: url) { _ in
            self.refreshControl?.endRefreshing()
        }
    }
}
