//
//  MovieDetailsView+TestExtensions.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import ViewInspector
import SwiftUI

@testable import ButterflyChallenge

extension MovieDetailsView {
    
    var isShowingLoadingIndicator: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.loading.rawValue)
        return view != nil
    }
    
    var isShowingMovieDetails: Bool {
        let view = try? inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.movieDetails.rawValue)
        return view != nil
    }
    
    var isShowingFailure: Bool {
        let view = try? failureView()
        return view != nil
    }
    
    func simulateRetryAction() throws {
        let view = try failureView()
        let button = try view.find(viewWithAccessibilityIdentifier: MovieDetailsFailureView.ViewIdentifiers.button.rawValue).button()
        try button.tap()
    }
    
    private func failureView() throws -> InspectableView<ViewType.ClassifiedView> {
        try inspect().find(viewWithAccessibilityIdentifier: MovieDetailsView.ViewIdentifiers.failureView.rawValue)
    }
    
}
