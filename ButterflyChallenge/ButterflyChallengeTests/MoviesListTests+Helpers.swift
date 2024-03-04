//
//  MoviesListTests+Helpers.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit
import XCTest

@testable import ButterflyChallenge

/// This class is built to fix an issue from iOS 17
/// With the introduction of `viewIsAppearing` in the View Life Cycle,
/// The refresh control only works when moving the `beginRefreshing` to this function
/// But in test targets we don't render the tested views in the screen, we don't assign them to the
/// key window, so this method of the life cycle is never executed, and the `isRefreshing` property
/// is never updated. Doing it could polute other tests, so the solution is to create a fake refresh control for testing purposes
private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

extension MovieViewCell {
    var titleText: String? { titleLabel.text }
    var releaseDateText: String? { releaseDateLabel.text }
    var renderedPosterImage: Data? { posterImageView.image?.pngData() }
    var isShowingImageLoadingIndicator: Bool { return posterImageContainer.isShimmering }
    var isShowingRetryAction: Bool { posterImageRetryButton.isHidden == false }
}

extension MoviesListViewController {
    func simulateUserInitiatedMoviesListReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateMovieCellVisible(at index: Int) -> MovieViewCell? {
        return movieView(at: index) as? MovieViewCell
    }
    
    @discardableResult
    func simulateMovieCellNotVisible(at row: Int) -> MovieViewCell? {
        let view = simulateMovieCellVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: movisListSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl!.isRefreshing == true
    }
    
    func simulateSearchForText(_ text: String) {
        searchBar.searchTextField.text = text
        searchBar.searchTextField.simulate(event: .editingChanged)
    }
    
    func simulateAppearence() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeToSupportiOS17()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFakeToSupportiOS17() {
        let fakeRefreshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fakeRefreshControl
    }
    
    func numberOfRenderedMovies() -> Int {
        return tableView.numberOfRows(inSection: movisListSection)
    }
    
    func movieView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedMovies() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: movisListSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var movisListSection: Int {
        return 0
    }
    
    var errorMessage: String? {
        errorView.message
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

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

extension XCTestCase {
    
    func anyError() -> Error {
        NSError(domain: "an error", code: 0)
    }
    
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "\(String(describing: object)) was expected to be removed from memory, possible retain cycle", file: file, line: line)
        }
    }
    
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
