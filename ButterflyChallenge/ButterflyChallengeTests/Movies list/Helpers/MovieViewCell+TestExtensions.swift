//
//  MovieViewCell+TestExtensions.swift
//  ButterflyChallengeTests
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

@testable import ButterflyChallenge

extension MovieViewCell {
    var titleText: String? { titleLabel?.text }
    var releaseDateText: String? { releaseDateLabel?.text }
    var renderedPosterImage: Data? { posterImageView?.image?.pngData() }
    var isShowingImageLoadingIndicator: Bool { return posterImageContainer?.isShimmering == true }
    var isShowingRetryAction: Bool { posterImageRetryButton?.isHidden == false }
    
    func simulateRetryAction() {
        posterImageRetryButton?.simulateTap()
    }
}
