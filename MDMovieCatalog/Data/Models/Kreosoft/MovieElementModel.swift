//
//  MovieElementModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct MovieElementModel: Codable {
    let id: UUID
    let name: String?
    let poster: String?
    let year: Int
    let country: String?
    let genres: [GenreModel]?
    let reviews: [ReviewShortModel]?
}
