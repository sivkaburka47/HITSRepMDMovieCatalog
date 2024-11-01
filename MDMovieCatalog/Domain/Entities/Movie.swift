//
//  Movie.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

struct Movie {
    let id: String
    let title: String
    let coverImageURL: URL
    let year: Int
    let country: String
    let genres: [String]
    let reviews: [Int]
    var isFavorite: Bool
}
