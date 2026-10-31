//
//  PersonByNameResponsePersonByNameResponse.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct PersonByNameResponsePersonByNameResponse: Codable {
    let total: Int
    let items: [PersonByNameNameResponse_items]
}
