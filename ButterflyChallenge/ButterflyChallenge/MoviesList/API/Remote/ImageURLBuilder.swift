//
//  ImageURLBuilder.swift
//  ButterflyChallenge
//
//  Created by Tulio Parreiras on 6/3/2024.
//

import Foundation

struct ImageURLBuilder {
    let path: String?
    
    var url: URL? {
        guard let path else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "image.tmdb.org"
        components.path = "/t/p/w154/".appending(path)
        return components.url
    }
}
