//
//  ProfileModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct ProfileModel: Codable {
    let id: UUID
    let nickName: String?
    let email: String
    let avatarLink: String
    let name: String
    let birthDate: String
    let gender: Gender
}
