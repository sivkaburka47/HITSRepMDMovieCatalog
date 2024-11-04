//
//  PersonByNameKinopoisk.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 04.11.2024.
//

struct PersonByNameKinopoisk: Codable {
    let total: Int
    let items: [PersonItemKinopoisk]
}

struct PersonItemKinopoisk: Codable {
    let kinopoiskId: Int
    let webUrl: String
    let nameRu: String?
    let nameEn: String?
    let sex: SexTypeKinopoisk?
    let posterUrl: String
}

enum SexTypeKinopoisk: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case unowned = "UNKNOWN"
}
