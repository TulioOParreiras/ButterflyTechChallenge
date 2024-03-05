//
//  MovieCellController.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import UIKit

protocol MovieCellControllerDelegate {
    func didRequestImage(for controller: MovieCellController)
    func didCancelImageRequest(for controller: MovieCellController)
}

final class MovieCellController: Identifiable, Hashable, Equatable {
    typealias ResourceViewModel = UIImage
    
    let id = UUID()
    let model: Movie
    let delegate: MovieCellControllerDelegate
    
    private var cell: MovieViewCell?
    
    init(model: Movie, delegate: MovieCellControllerDelegate) {
        self.model = model
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.titleLabel?.text = model.title
        cell?.releaseDateLabel?.text = model.releaseDate
        cell?.posterImageRetryButton?.isHidden = true
        cell?.onRetry = preload
        cell?.posterImageView?.image = nil
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
    
    func displayImage(_ image: UIImage?) {
        cell?.posterImageView?.setImageAnimated(image)
    }
    
    func displayLoading(_ isLoading: Bool) {
        cell?.posterImageContainer?.isShimmering = isLoading
    }
    
    func displayError(_ message: String?) {
        cell?.posterImageRetryButton?.isHidden = message == nil
    }

    private func releaseCellForReuse() {
        cell = nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MovieCellController, rhs: MovieCellController) -> Bool {
        lhs.id == rhs.id
    }
}
