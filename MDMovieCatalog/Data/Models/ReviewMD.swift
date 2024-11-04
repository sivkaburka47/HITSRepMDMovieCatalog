//
//  ReviewMD.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 04.11.2024.
//

import Foundation

struct ReviewMD: Codable {
    let reviewText: String
    let rating: Int
    let isAnonymous: Bool
}
