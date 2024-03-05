//
//  MovieDetailsContentView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import SwiftUI

struct MovieDetailsContentView: View {
    enum Constants {
        static let viewPadding = CGFloat(16)
        static let contentStackPadding = CGFloat(16)
        static let topContentStackSpacing = CGFloat(8)
        static let titleStackSpacing = CGFloat(4)
        static let durationStackPadding = CGFloat(8)
        static let overviewStackPadding = CGFloat(8)
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
            
            Text(movieDetails.originalTitle)
                .font(.caption)
            
        }
    }
    
    var durationStack: some View {
        HStack(spacing: Constants.durationStackPadding, content: {
            Text(movieDetails.releaseDate)
            
            Text("|")
            
            Text(movieDetails.duration)
        })
        .font(.subheadline)
    }
    
    var overviewStack: some View {
        HStack(spacing: Constants.overviewStackPadding) {
            imageContainer
            
            Text(movieDetails.overview)
                .font(.body)
        }
    }
    
    var imageContainer: some View {
        ZStack {
            Color.secondary
                .frame(width: 100, height: 150)
            imageContent
        }
    }
    
    @ViewBuilder
    var imageContent: some View {
        switch viewModel.imageState {
        case .loading:
            ProgressView()
        case .loaded(let data):
            if let image = UIImage(data: data) {
                Image(uiImage: image)
            } else {
                Image(systemName: "photo")
            }
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
}

#if DEBUG
final class ImageLoaderMock: MovieImageDataLoader {
    let loadResult: LoadResult?
    
    init(loadResult: LoadResult?) {
        self.loadResult = loadResult
    }
    
    struct TaskMock: DataLoaderTask {
        func cancel() { }
    }
    
    func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DataLoaderTask {
        if let loadResult {
            completion(loadResult)
        }
        return TaskMock()
    }
}

extension MovieDetails {
    static var duneMovie: MovieDetails {
        MovieDetails(
            id: "1",
            title: "Dune",
            posterImageURL: URL(string: "https://any-url.com"),
            releaseDate: "2021",
            overview: "A noble family becomes embroiled in a war for control over the galaxy's most valuable asset while its heir becomes troubled by visions of a dark future",
            originalTitle: "Dune: Part One (original title)",
            duration: "2h 35m"
        )
    }
}
#endif

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
