//
//  MovieShimmeringCell.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

final class MovieShimmeringCell: UITableViewCell {
    @IBOutlet private(set) weak var titleView: UIView?
    @IBOutlet private(set) weak var releaseDateView: UIView?
    @IBOutlet private(set) weak var posterImageContainer: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [titleView, releaseDateView, posterImageContainer].forEach { $0?.isShimmering = true }
    }
}

