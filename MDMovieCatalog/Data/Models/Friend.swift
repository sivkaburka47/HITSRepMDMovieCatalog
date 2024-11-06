//
//  Friend.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 07.11.2024.
//

import Foundation

struct Friend: Codable {
    let userId: String
    let nickName: String
    let avatar: String?
    let moviesID: String
    let rating: Int
}

