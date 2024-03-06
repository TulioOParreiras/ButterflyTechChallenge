//
//  MovieDetailsMapper.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

final class MovieDetailsMapper {
    
    private struct RemoteMovieDetails: Decodable {
        let id: Int
        let title: String
        let poster_path: String?
        let release_date: String
        let overview: String
        let original_title: String?
        let runtime: Int?
        
        var toMovie: MovieDetails {
            return MovieDetails(
                id: String(describing: id),
                title: title,
                posterImageURL: ImageURLBuilder(path: poster_path).url,
                releaseDate: MovieDateFormatter.getYear(from: release_date),
                overview: overview,
                originalTitle: original_title?.appending(" (original title)"),
                duration: DurationFormatter(durationInMinutes: runtime).formattedDuration()
            )
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> MovieDetails {
        return try JSONDecoder().decode(RemoteMovieDetails.self, from: data).toMovie
    }
}
