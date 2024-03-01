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


extension MoviesListViewController {
    func simulateUserInitiatedMoviesListReload() {
        refreshControl?.simulatePullToRefresh()
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
    
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "\(String(describing: object)) was expected to be removed from memory, possible retain cycle", file: file, line: line)
        }
    }
    
}

