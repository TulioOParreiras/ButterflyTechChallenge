//
//  MoviesListViewController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: MovieCellControllerDelegate where T: MovieCellControllerDelegate {
    func didRequestImage(for controller: MovieCellController) {
        object?.didRequestImage(for: controller)
    }
    
    func didCancelImageRequest(for controller: MovieCellController) {
        object?.didCancelImageRequest(for: controller)
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}

protocol MovieCellControllerDelegate {
    func didRequestImage(for controller: MovieCellController)
    func didCancelImageRequest(for controller: MovieCellController)
}

final class MovieCellController {
    typealias ResourceViewModel = UIImage
    
    let model: Movie
    let delegate: MovieCellControllerDelegate
    
    private var cell: MovieViewCell?
    
    init(model: Movie, delegate: MovieCellControllerDelegate) {
        self.model = model
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.titleLabel.text = model.title
        cell?.releaseDateLabel.text = model.releaseDate
        cell?.posterImageRetryButton.isHidden = true
        cell?.onRetry = preload
        delegate.didRequestImage(for: self)
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage(for: self)
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest(for: self)
    }
    
    func displayImage(_ image: UIImage) {
        cell?.posterImageView.image = image
    }
    
    func displayLoading(_ isLoading: Bool) {
        cell?.posterImageContainer.isShimmering = isLoading
    }
    
    func displayError(_ message: String?) {
        cell?.posterImageRetryButton.isHidden = message == nil
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}


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
    let posterImageContainer = UIView()
    lazy var posterImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc func retryButtonTapped() {
        onRetry?()
    }
    
}

final class MoviesListViewController: UITableViewController {
    let moviesLoader: MoviesDataLoader
    let imageDataLoader: MovieImageDataLoader
    lazy var searchBar = UISearchBar()
    lazy var errorView = ErrorView()
    
    var tableModel = [MovieCellController]()
    private var loadingControllers = [IndexPath: MovieCellController]()
    private var loadingTasks = [IndexPath: MovieImageDataLoaderTask]()
    
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
            guard let self else { return }
            do {
                let moviesList = try result.get()
                self.tableModel = moviesList.map { MovieCellController(model: $0, delegate: WeakRefVirtualProxy(self))}
            } catch {
                self.errorView.message = "Couldn't connect to server"
            }
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
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

extension MoviesListViewController: MovieCellControllerDelegate {
    fileprivate func indexPath(for controller: MovieCellController) -> IndexPath? {
        loadingControllers.first(where: { $0.value.model.id == controller.model.id })?.key
    }
    
    func didRequestImage(for controller: MovieCellController) {
        guard let indexPath = indexPath(for: controller) else { return }
        controller.displayLoading(true)
        let task = imageDataLoader.loadImageData(from: controller.model.posterImageURL, completion: { [weak controller] result in
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
        })
        loadingTasks[indexPath] = task
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
        tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension UIView {
    public var isShimmering: Bool {
        set {
            if newValue {
                startShimmering()
            } else {
                stopShimmering()
            }
        }
        
        get {
            return layer.mask?.animation(forKey: shimmerAnimationKey) != nil
        }
    }
    
    private var shimmerAnimationKey: String {
        return "shimmer"
    }
    
    private func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.25
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    private func stopShimmering() {
        layer.mask = nil
    }
}
