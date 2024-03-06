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
                return Movie(
                    id: String(describing: id),
                    title: title,
                    posterImageURL: ImageURLBuilder(path: poster_path).url,
                    releaseDate: MovieDateFormatter.getYear(from: release_date)
                )
            }
        }

        var images: [Movie] {
            results.map { $0.toMovie }
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Movie] {
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.images
    }
}
