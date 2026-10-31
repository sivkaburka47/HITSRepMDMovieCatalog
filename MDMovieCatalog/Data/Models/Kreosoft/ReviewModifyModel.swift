//
//  ReviewModifyModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct ReviewModifyModel: Codable {
    let reviewText: String
    let rating: Int
    let isAnonymous: Bool
}
