//
//  MovieDetailsView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import SwiftUI

struct MovieDetailsView: View {
    enum ViewIdentifiers: String {
        case loading = "loading-indicator"
        case movieDetails = "movie-details-view"
        case failureView = "failure-view"
    }
    
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        content
            .onAppear {
                viewModel.onViewLoad()
            }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView().accessibilityIdentifier(ViewIdentifiers.loading.rawValue)
        case .loaded(let movie):
            MovieDetailsContentView(movie: movie).accessibilityIdentifier(ViewIdentifiers.movieDetails.rawValue)
        case .failure(let error):
            MovieDetailsFailureView {
                viewModel.onDetailsLoadRetry()
            }.accessibilityIdentifier(ViewIdentifiers.failureView.rawValue)
        case .empty:
            EmptyView()
        }
    }
}

#Preview {
    MovieDetailsView(viewModel: MovieDetailsViewModel(movie: .mock, movieDetailsLoader: MovieDetailsLoaderMock()))
}
