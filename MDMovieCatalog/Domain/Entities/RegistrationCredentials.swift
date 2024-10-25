//
//  RegistrationCredentials.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 15.10.2024.
//
import Foundation

struct RegistrationCredentials: Codable {
    let userName: String
    let name: String
    let password: String
    let email: String
    let birthDate: String
    let gender: Int
}
