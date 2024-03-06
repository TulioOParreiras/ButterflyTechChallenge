//
//  MovieShimmeringCell+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

extension MovieShimmeringCell {
    var isShimmeringImage: Bool { posterImageContainer?.isShimmering == true }
    var isShimmeringTitle: Bool { titleView?.isShimmering == true }
    var isShimmeringDate: Bool { releaseDateView?.isShimmering == true }
}
