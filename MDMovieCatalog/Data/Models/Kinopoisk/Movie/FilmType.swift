//
//  FilmType.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

enum FilmType: String, Codable {
    case film = "FILM"
    case tvShow = "TV_SHOW"
    case video = "VIDEO"
    case miniSeries = "MINI_SERIES"
    case tvSeries = "TV_SERIES"
    case unknown = "UNKNOWN"
}
