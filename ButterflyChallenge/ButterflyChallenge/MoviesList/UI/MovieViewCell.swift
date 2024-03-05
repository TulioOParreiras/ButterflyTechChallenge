//
//  MovieViewCell.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

final class MovieViewCell: UITableViewCell {
    @IBOutlet private(set) weak var titleLabel: UILabel?
    @IBOutlet private(set) weak var releaseDateLabel: UILabel?
    @IBOutlet private(set) weak var posterImageView: UIImageView?
    @IBOutlet private(set) weak var posterImageContainer: UIView?
    @IBOutlet private(set) weak var posterImageRetryButton: UIButton?
    
    var onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}
