//
//  MovieListMapper.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

final class MovieDateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let invalidDateMessage = "Release date unavailable"
    
    static func getYear(from dateString: String) -> String {
        guard let date = dateFormatter.date(from: dateString) else { return invalidDateMessage }
        let components = Calendar.current.dateComponents([.year], from: date)
        guard let year = components.year else { return invalidDateMessage }
        return String(describing: year)
    }
}

final class MovieListMapper {
    private struct Root: Decodable {
        
        private let results: [RemoteMovie]
        
        private struct RemoteMovie: Decodable {
            let id: Int
            let title: String
            let poster_path: String?
            let release_date: String
            
            var toMovie: Movie {
                var posterImageURL: URL?
                if let poster_path {
                    posterImageURL = URL(string: "https://image.tmdb.org/t/p/w154\(poster_path)")
                }
                return Movie(
                    id: String(describing: id),
                    title: title,
                    posterImageURL: posterImageURL,
                    releaseDate: MovieDateFormatter.getYear(from: release_date)
                )
            }
        }

        var images: [Movie] {
            results.map { $0.toMovie }
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Movie] {
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.images
    }
}

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
