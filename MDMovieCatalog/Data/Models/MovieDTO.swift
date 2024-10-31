//
//  MovieDTO.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

struct MovieResponse: Codable {
    let movies: [MovieDTO]
    let pageInfo: PageInfo
}

struct FavoriteResponse: Codable {
    let movies: [MovieDTO]
}

struct MovieDTO: Codable {
    let id: String
    let name: String
    let poster: String
    let year: Int
    let country: String
    let genres: [GenreDTO]
    let reviews: [ReviewDTO]
}

struct GenreDTO: Codable {
    let id: String
    let name: String
}

struct ReviewDTO: Codable {
    let id: String
    let rating: Int
}

struct PageInfo: Codable {
    let pageSize: Int
    let pageCount: Int
    let currentPage: Int
}

extension Movie {
    init(from movieDTO: MovieDTO) {
        self.id = movieDTO.id
        self.title = movieDTO.name
        self.coverImageURL = URL(string: movieDTO.poster)!
        self.year = movieDTO.year
        self.country = movieDTO.country
        self.genres = movieDTO.genres.map { $0.name }
    }
}
