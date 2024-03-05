//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

final class MoviesListViewController: UITableViewController {
    
    lazy var searchBar = UISearchBar()
    
    @IBOutlet private(set) weak var errorView: ErrorView?
    
    private var loadingControllers = [IndexPath: MovieCellController]()
    private var tableModel = [MovieCellController]() {
        didSet { tableView.reloadData()}
    }
    private var isLoading = false {
        didSet { tableView.reloadData()}
    }
    
    var viewModel: MoviesListViewModel? {
        didSet {
            viewModel?.onLoadingStateChange = { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            viewModel?.onMoviesListLoad = { [weak self] movies in
                self?.tableModel = movies
                self?.tableView.reloadData()
            }
            viewModel?.onMoviesListLoadError = { [weak self] errorMessage in
                self?.errorView?.message = errorMessage
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
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
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    @objc func refresh() {
        guard let searchText = searchBar.text else { return }
        viewModel?.searchMovie(searchText)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> MovieCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func cancelImageLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
}

// MARK: - UISearchBarDelegate

extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refresh()
    }
    
}

// MARK: - UITableViewDataSource

extension MoviesListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isLoading ? 3 : tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isLoading else {
            let cell: MovieShimmeringCell = tableView.dequeueReusableCell()
            return cell
        }
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
}

// MARK: - UITableViewDelegate

extension MoviesListViewController {
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(forRowAt: indexPath)
    }
    
}

// MARK: - UITableViewDataSourcePrefetching

extension MoviesListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelImageLoad(forRowAt: indexPath)
        }
    }
    
}
