//
//  ProfileModel.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 27.10.2024.
//

import Foundation

struct ProfileModel: Codable {
    var id: String
    var nickName: String?
    var email: String
    var avatarLink: String?
    var name: String
    var birthDate: String
    var gender: Int
}
