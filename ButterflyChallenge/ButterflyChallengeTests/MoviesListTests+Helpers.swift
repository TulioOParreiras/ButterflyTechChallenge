//
//  MoviesListTests+Helpers.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 1/3/2024.
//

import UIKit

@testable import ButterflyChallenge

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
