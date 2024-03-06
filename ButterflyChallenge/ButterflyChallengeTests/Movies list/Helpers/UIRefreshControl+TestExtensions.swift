//
//  UIRefreshControl+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
