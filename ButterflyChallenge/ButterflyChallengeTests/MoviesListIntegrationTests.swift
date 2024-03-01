//
//  ButterflyChallengeTests.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import XCTest
@testable import ButterflyChallenge

protocol MoviesDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadMoviesData(from url: URL, completion: @escaping (Result) -> Void)
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
        refresh()
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        guard let url = URL(string: "https://any-url.com") else { return }
        moviesLoader.loadMoviesData(from: url, completion: { _ in })
    }
}

class LoaderSpy: MoviesDataLoader {
    var loadCallCount = 0
    
    func loadMoviesData(from url: URL, completion: @escaping (MoviesDataLoader.Result) -> Void) {
        loadCallCount += 1
    }
}

final class MoviesListIntegrationTests: XCTestCase { 
    
    func test_loadMoviesActions_requestLoadMovies() {
        let loader = LoaderSpy()
        let sut = MoviesListViewController(moviesLoader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedMoviesListReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
}

extension MoviesListViewController {
    func simulateUserInitiatedMoviesListReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
