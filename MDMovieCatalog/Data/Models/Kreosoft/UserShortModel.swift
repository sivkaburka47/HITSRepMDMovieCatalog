//
//  UserShortModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct UserShortModel: Codable {
    let userId: UUID
    let nickName: String?
    let avatar: String?
}
