//
//  MovieDetails.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 03.11.2024.
//

import Foundation

struct MovieDetails: Codable {
    let id: String
    let name: String?
    let poster: String?
    let year: Int
    let country: String?
    let genres: [Genre]?
    let reviews: [Review]?
    let time: Int
    let tagline: String?
    let description: String?
    let director: String?
    let budget: Int?
    let fees: Int?
    let ageLimit: Int
}

struct Genre: Codable {
    let id: String
    let name: String?
}

struct Review: Codable {
    let id: String
    let rating: Int
    let reviewText: String?
    let isAnonymous: Bool
    let createDateTime: String
    let author: Author
}

struct Author: Codable {
    let userId: String
    let nickName: String?
    let avatar: String?
}
