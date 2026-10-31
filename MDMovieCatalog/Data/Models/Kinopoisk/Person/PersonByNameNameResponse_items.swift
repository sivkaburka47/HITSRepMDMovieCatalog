//
//  PersonByNameNameResponse_items.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct PersonByNameNameResponse_items: Codable {
    let kinopoiskId: Int
    let webUrl: String
    let nameRu: String?
    let nameEn: String?
    let sex: Sex?
    let posterUrl: String?
}
