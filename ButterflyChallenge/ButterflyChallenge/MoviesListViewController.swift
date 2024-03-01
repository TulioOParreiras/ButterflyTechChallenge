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
    lazy var searchBar = UISearchBar()
    
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
        configureSearchBar()
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func configureSearchBar() {
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = "Type to search a movie"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        view.addSubview(searchBar)
    }
    
    @objc func refresh() {
        guard let url = URL(string: "https://any-url.com") else { return }
        refreshControl?.beginRefreshing()
        moviesLoader.loadMoviesData(from: url) { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refresh()
    }
}
