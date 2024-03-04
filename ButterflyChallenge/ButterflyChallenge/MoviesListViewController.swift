//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

public protocol MovieImageDataLoaderTask {
    func cancel()
}

public protocol MovieImageDataLoader {
    typealias LoadResult = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> MovieImageDataLoaderTask
}


protocol MoviesDataLoader {
    typealias LoadResult = Swift.Result<[Movie], Error>
    
    func loadMoviesData(from url: URL, completion: @escaping (LoadResult) -> Void)
}

struct Movie {
    let id: String
    let title: String
    let posterImageURL: URL
    let releaseDate: String
}

final class ErrorView: UIView {
    let label = UILabel()
    
    var message: String? {
        get { return label.text }
        set { label.text = newValue }
    }
}

final class MovieViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let releaseDateLabel = UILabel()
    let posterImageView = UIImageView()
}

final class MoviesListViewController: UITableViewController {
    let moviesLoader: MoviesDataLoader
    let imageDataLoader: MovieImageDataLoader
    lazy var searchBar = UISearchBar()
    lazy var errorView = ErrorView()
    
    var moviesList = [Movie]()
    
    var imageTasks = [IndexPath: MovieImageDataLoaderTask]()
    
    init(moviesLoader: MoviesDataLoader, imageDataLoader: MovieImageDataLoader) {
        self.moviesLoader = moviesLoader
        self.imageDataLoader = imageDataLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MovieViewCell.self, forCellReuseIdentifier: String(describing: MovieViewCell.self))
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
        errorView.message = nil
        moviesLoader.loadMoviesData(from: url) { [weak self] result in
            do {
                self?.moviesList = try result.get()
            } catch {
                self?.errorView.message = "Couldn't connect to server"
            }
            self?.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    private func loadImage(at indexPath: IndexPath) {
        imageTasks[indexPath] = imageDataLoader.loadImageData(from: moviesList[indexPath.row].posterImageURL, completion: { _ in })
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        imageTasks[indexPath]?.cancel()
        imageTasks[indexPath] = nil
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
        moviesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MovieViewCell.self), for: indexPath) as! MovieViewCell
        cell.titleLabel.text = moviesList[indexPath.row].title
        cell.releaseDateLabel.text = moviesList[indexPath.row].releaseDate
        loadImage(at: indexPath)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension MoviesListViewController {
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
    
}

// MARK: - UITableViewDataSourcePrefetching

extension MoviesListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            loadImage(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelImageLoad(at: indexPath)
        }
    }
    
}
