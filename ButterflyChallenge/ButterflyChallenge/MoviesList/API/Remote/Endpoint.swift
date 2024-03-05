//
//  Endpoint.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 5/3/2024.
//

import Foundation

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

/// Both `api_key` and `host`  ideally shoult not be hard coded
/// Those are sensitive information, and should be injected via CI
/// Since this project there is no certificate pinning, doesn't make a difference
/// Anyone could intercept the requests with proxies like Charles
extension Endpoint {
    static func search(
        matching query: String,
        page: String
    ) -> Endpoint {
        return Endpoint(
            path: "/3/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: page),
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "api_key", value: "bc7ad8316e724104902012f2f86bc86a")
            ]
        )
    }
}

extension Endpoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
