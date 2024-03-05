//
//  WeakRefVirtualProxy.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: MovieCellControllerDelegate where T: MovieCellControllerDelegate {
    func didRequestImage(for controller: MovieCellController) {
        object?.didRequestImage(for: controller)
    }
    
    func didCancelImageRequest(for controller: MovieCellController) {
        object?.didCancelImageRequest(for: controller)
    }
}
