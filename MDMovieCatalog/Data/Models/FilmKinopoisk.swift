//
//  FilmKinopoisk.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 04.11.2024.
//

import Foundation

struct FilmKinopoisk: Codable {
    let total: Int
    let totalPages: Int
    let items: [FilmItemKinoPoisk]
}

struct FilmItemKinoPoisk: Codable {
    let kinopoiskId: Int
    let imdbId: String?
    let nameRu: String?
    let nameEn: String?
    let nameOriginal: String?
    let countries: [CountryKinoPoisk]
    let genres: [GenreKinoPoisk]
    let ratingKinopoisk: Double?
    let ratingImdb: Double?
    let year: Int?
    let type: FilmTypeKinoPoisk
    let posterUrl: String
    let posterUrlPreview: String
}

struct CountryKinoPoisk: Codable {
    let country: String
}

struct GenreKinoPoisk: Codable {
    let genre: String
}

enum FilmTypeKinoPoisk: String, Codable {
    case film = "FILM"
    case tvShow = "TV_SHOW"
    case video = "VIDEO"
    case miniSeries = "MINI_SERIES"
    case tvSeries = "TV_SERIES"
    case unknown = "UNKNOWN"
}
