//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

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

final class MovieViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let releaseDateLabel = UILabel()
    let posterImageView = UIImageView()
}

final class MoviesListViewController: UITableViewController {
    let moviesLoader: MoviesDataLoader
    lazy var searchBar = UISearchBar()
    
    var moviesList = [Movie]()
    
    init(moviesLoader: MoviesDataLoader) {
        self.moviesLoader = moviesLoader
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
        moviesLoader.loadMoviesData(from: url) { [weak self] result in
            do {
                self?.moviesList = try result.get()
            } catch {
                print("Failed to load movies with error \(error)")
            }
            self?.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        }
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
        return cell
    }
    
}
