//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

final class MoviesListViewController: UITableViewController {
    var moviesLoader: MoviesDataLoader?
    var imageDataLoader: MovieImageDataLoader?
    lazy var searchBar = UISearchBar()
    @IBOutlet private(set) weak var errorView: ErrorView?
    
    var tableModel = [MovieCellController]()
    private var loadingControllers = [IndexPath: MovieCellController]()
    private var loadingMoviesTask: DataLoaderTask?
    private var loadingTasks = [IndexPath: DataLoaderTask]()
    
    var isLoading = false
    
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
        guard let url = Endpoint.search(matching: searchBar.text ?? "", page: "1").url else { return }
        errorView?.message = nil
        loadingMoviesTask?.cancel()
        isLoading = true
        tableView.reloadData()
        loadingMoviesTask = moviesLoader?.loadMoviesData(from: url) { [weak self] result in
            self?.onMoviesLoad(result)
        }
    }
    
    private func onMoviesLoad(_ result: MoviesDataLoader.LoadResult) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.onMoviesLoad(result)
            }
            return
        }
        loadingMoviesTask = nil
        loadingControllers = [:]
        loadingTasks = [:]
        isLoading = false
        do {
            let moviesList = try result.get()
            tableModel = moviesList.map { MovieCellController(model: $0, delegate: WeakRefVirtualProxy(self))}
        } catch {
            errorView?.message = "Couldn't connect to server"
        }
        refreshControl?.endRefreshing()
        tableView.reloadData()
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

// MARK: - MovieCellControllerDelegate

extension MoviesListViewController: MovieCellControllerDelegate {
    fileprivate func indexPath(for controller: MovieCellController) -> IndexPath? {
        loadingControllers.first(where: { $0.value.model.id == controller.model.id })?.key
    }
    
    func didRequestImage(for controller: MovieCellController) {
        guard 
            let indexPath = indexPath(for: controller),
            let url = controller.model.posterImageURL
        else {
            let image = UIImage(systemName: "photo")
            controller.displayImage(image)
            return
        }
        controller.displayLoading(true)
        let task = imageDataLoader?.loadImageData(from: url, completion: { [weak controller, weak self] result in
            self?.onImageLoad(controller: controller, result: result)
        })
        loadingTasks[indexPath] = task
    }
    
    private func onImageLoad(controller: MovieCellController?, result: MovieImageDataLoader.LoadResult) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.onImageLoad(controller: controller, result: result)
            }
            return
        }
        controller?.displayLoading(false)
        do {
            let data = try result.get()
            if let image = UIImage(data: data) {
                controller?.displayImage(image)
                controller?.displayError(nil)
            } else {
                controller?.displayError("Invalid image")
            }
        } catch {
            controller?.displayError("Failure to load image")
        }
    }
    
    func didCancelImageRequest(for controller: MovieCellController) {
        guard let indexPath = indexPath(for: controller) else { return }
        controller.displayLoading(false)
        loadingTasks[indexPath]?.cancel()
        loadingTasks[indexPath] = nil
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
