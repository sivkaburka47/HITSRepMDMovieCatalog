//
//  UserRegisterModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct UserRegisterModel: Codable {
    let userName: String
    let name: String
    let password: String
    let email: String
    let birthDate: String
    let gender: Gender
}
