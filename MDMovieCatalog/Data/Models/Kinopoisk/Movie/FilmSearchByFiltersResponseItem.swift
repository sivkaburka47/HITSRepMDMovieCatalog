//
//  FilmSearchByFiltersResponseItem.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct FilmSearchByFiltersResponseItem: Codable {
    let kinopoiskId: Int
    let imdbId: Int?
    let nameRu: String?
    let nameEn: String?
    let nameOriginal: String?
    let countries: [CountryModel]
    let genres: [GenreModel]
    let ratingKinopoisk: Double?
    let ratingImdb: Double?
    let year: Double?
    let type: FilmType
    let posterUrl: String
    let posterUrlPreview: String
    
    struct CountryModel: Codable {
        let country: String
    }

    struct GenreModel: Codable {
        let genre: String
    }
}
