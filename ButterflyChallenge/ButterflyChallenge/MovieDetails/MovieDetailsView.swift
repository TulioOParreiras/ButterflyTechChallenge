//
//  MovieDetailsView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import SwiftUI

struct MovieDetails {
    let id: String
    let title: String
    let posterImageURL: URL?
    let releaseDate: String
    let overview: String
    let originalTitle: String
    let duration: String
}

protocol MovieDetailsLoader {
    typealias LoadResult = Result<MovieDetails, Error>
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void)
}

enum MovieDetailsViewState {
    case loading
    case loaded(MovieDetails)
    case failure(Error)
    case empty
}

final class MovieDetailsViewModel: ObservableObject {
    let movie: Movie
    let movieDetailsLoader: MovieDetailsLoader
    
    @Published var viewState: MovieDetailsViewState = .empty
    
    init(movie: Movie, movieDetailsLoader: MovieDetailsLoader) {
        self.movie = movie
        self.movieDetailsLoader = movieDetailsLoader
    }
    
    func onViewLoad() {
        viewState = .loading
        movieDetailsLoader.loadMovieData(from: movie, completion: { [weak self] result in
            do {
                let value = try result.get()
                self?.viewState = .loaded(value)
            } catch {
                self?.viewState = .failure(error)
            }
        })
    }
}

struct MovieDetailsView: View {
    enum ViewIdentifiers: String {
        case loading = "loading-indicator"
        case movieDetails = "movie-details-view"
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
            EmptyView()
        case .empty:
            EmptyView()
        }
    }
}

struct MovieDetailsContentView: View {
    let movie: MovieDetails
    
    var body: some View {
        Text("")
    }
}

#if DEBUG
class MovieDetailsLoaderMock: MovieDetailsLoader {
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void) {
        completion(.success(.mock))
    }
}

extension Movie {
    static var mock: Movie {
        Movie(id: "1", title: "A title", posterImageURL: nil, releaseDate: "A date")
    }
}

extension MovieDetails {
    static var mock: MovieDetails {
        MovieDetails(
            id: "1",
            title: "A title",
            posterImageURL: nil,
            releaseDate: "A date",
            overview: "An overview",
            originalTitle: "A title",
            duration: "2h 30m"
        )
    }
}
#endif

#Preview {
    MovieDetailsView(viewModel: MovieDetailsViewModel(movie: .mock, movieDetailsLoader: MovieDetailsLoaderMock()))
}
