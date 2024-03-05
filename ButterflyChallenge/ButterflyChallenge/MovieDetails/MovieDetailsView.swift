//
//  MovieDetailsView.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import SwiftUI

protocol MovieDetailsLoader {
    typealias LoadResult = Result<Movie, Error>
    
    func loadMovieData(from movie: Movie, completion: @escaping (LoadResult) -> Void)
}

final class MovieDetailsViewModel: ObservableObject {
    let movie: Movie
    let movieDetailsLoader: MovieDetailsLoader
    
    init(movie: Movie, movieDetailsLoader: MovieDetailsLoader) {
        self.movie = movie
        self.movieDetailsLoader = movieDetailsLoader
    }
    
    func onViewLoad() {
        movieDetailsLoader.loadMovieData(from: movie, completion: { _ in })
    }
}

struct MovieDetailsView: View {
    
    @ObservedObject var viewModel: MovieDetailsViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                viewModel.onViewLoad()
            }
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
#endif

#Preview {
    MovieDetailsView(viewModel: MovieDetailsViewModel(movie: .mock, movieDetailsLoader: MovieDetailsLoaderMock()))
}
