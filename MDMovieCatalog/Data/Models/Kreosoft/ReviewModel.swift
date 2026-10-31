//
//  ReviewModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct ReviewModel: Codable {
    let id: UUID
    let rating: Int
    let reviewText: String?
    let isAnonymous: Bool
    let createDateTime: String
    let author: UserShortModel
}
