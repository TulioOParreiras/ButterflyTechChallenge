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
    let imageLoader: MovieImageDataLoader
    
    var body: some View {
        VStack {
            content
        }
        .onAppear {
            viewModel.onViewLoad()
        }
        .onDisappear {
            viewModel.onViewDisappear()
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .accessibilityIdentifier(ViewIdentifiers.loading.rawValue)
        case .loaded(let movie):
            MovieDetailsContentView(
                viewModel: MovieDetailsContentViewModel(
                    movieDetails: movie,
                    imageLoader: imageLoader
                )
            ).accessibilityIdentifier(ViewIdentifiers.movieDetails.rawValue)
        case .failure:
            MovieDetailsFailureView {
                viewModel.onDetailsLoadRetry()
            }.accessibilityIdentifier(ViewIdentifiers.failureView.rawValue)
        case .empty:
            EmptyView()
        }
    }
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            movie: .mock,
            movieDetailsLoader: MovieDetailsLoaderMock(
                result: .success(.duneMovie))
        ),
        imageLoader: ImageLoaderMock(
            loadResult: .success(UIImage(systemName: "photo.fill")!.pngData()!)
        )
    )
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            movie: .mock,
            movieDetailsLoader: MovieDetailsLoaderMock(
                result: .failure(NSError(domain: "", code: 0)))
        ),
        imageLoader: ImageLoaderMock(
            loadResult: .failure(NSError(domain: "", code: 0)))
    )
}

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            movie: .mock,
            movieDetailsLoader: MovieDetailsLoaderMock(result: nil)),
        imageLoader: ImageLoaderMock(loadResult: nil)
    )
}
