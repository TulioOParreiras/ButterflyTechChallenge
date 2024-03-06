//
//  MovieDetailsContentView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import SwiftUI

struct MovieDetailsContentView: View {
    enum ViewIdentifiers: String {
        case loadingIndicator = "image-loading-indicator"
        case posterImage = "poster-image-view"
    }
    
    enum Constants {
        static let viewPadding = CGFloat(16)
        static let contentStackPadding = CGFloat(16)
        static let topContentStackSpacing = CGFloat(8)
        static let titleStackSpacing = CGFloat(4)
        static let durationStackPadding = CGFloat(8)
        static let overviewStackPadding = CGFloat(8)
        static let imageWidth = CGFloat(100)
        static let imageHeight = CGFloat(150)
    }
    
    @ObservedObject var viewModel: MovieDetailsContentViewModel
    
    var movieDetails: MovieDetails { viewModel.movieDetails }
    
    var body: some View {
        ScrollView {
            contentStack
        }
        .padding(Constants.viewPadding)
        .onAppear {
            viewModel.onViewLoad()
        }
        .onDisappear {
            viewModel.onViewDisappear()
        }
    }
    
    var contentStack: some View {
        VStack(alignment: .leading, spacing: Constants.contentStackPadding) {
            topContentStack
            overviewStack
        }
    }
    
    var topContentStack: some View {
        VStack(alignment: .leading, spacing: Constants.topContentStackSpacing) {
            titleStack
            durationStack
        }
    }
    
    var titleStack: some View {
        VStack(alignment: .leading, spacing: Constants.titleStackSpacing) {
            Text(movieDetails.title)
                .font(.largeTitle)
            
            if let originalTitle = movieDetails.originalTitle {
                Text(originalTitle)
                    .font(.caption)
            }
            
        }
    }
    
    var durationStack: some View {
        HStack(spacing: Constants.durationStackPadding, content: {
            Text(movieDetails.releaseDate)
            
            if let duration = movieDetails.duration {
                Text("|")
                
                Text(duration)
            }
        })
        .font(.subheadline)
    }
    
    var overviewStack: some View {
        HStack(alignment: .top, spacing: Constants.overviewStackPadding) {
            imageContainer
            
            Text(movieDetails.overview)
                .font(.body)
        }
    }
    
    var imageContainer: some View {
        ZStack {
            Color.secondary
                .opacity(0.5)
                .frame(width: Constants.imageWidth, height: Constants.imageHeight)
            imageContent
        }
    }
    
    @ViewBuilder
    var imageContent: some View {
        switch viewModel.imageState {
        case .loading:
            ProgressView()
                .accessibilityIdentifier(ViewIdentifiers.loadingIndicator.rawValue)
        case .loaded(let data):
            makeImage(from: data)
                .accessibilityIdentifier(ViewIdentifiers.posterImage.rawValue)
        case .failure:
            Button(action: {
                viewModel.onImageLoadRetry()
            }, label: {
                Text("↻")
                    .font(.largeTitle)
                    .tint(.black)
            })
        case .empty:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func makeImage(from data: Data) -> some View {
        if let image = UIImage(data: data) {
            Image(uiImage: image)
        } else {
            Image(systemName: "photo")
        }
    }
}

#Preview {
    MovieDetailsContentView(
        viewModel: MovieDetailsContentViewModel(
            movieDetails: .duneMovie,
            imageLoader: ImageLoaderMock(loadResult: .success(UIImage(systemName: "photo.fill")!.pngData()!))
        )
    )
}

#Preview {
    MovieDetailsContentView(
        viewModel: MovieDetailsContentViewModel(
            movieDetails: .duneMovie,
            imageLoader: ImageLoaderMock(loadResult: .failure(NSError(domain: "", code: 0)))
        )
    )
}

#Preview {
    MovieDetailsContentView(
        viewModel: MovieDetailsContentViewModel(
            movieDetails: .duneMovie,
            imageLoader: ImageLoaderMock(loadResult: nil)
        )
    )
}
