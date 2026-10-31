//
//  FilmSearchByFiltersResponse.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct FilmSearchByFiltersResponse: Codable {
    let total: Int
    let totalPages: Int
    let items: [FilmSearchByFiltersResponseItem]
}
