//
//  FavoriteAPIEndpoint.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 31.10.2024.
//

import Foundation

struct FavoriteAPIEndpoint {
    
    static func getFavorites(token: String) -> URL? {
        return URL(string: "https://react-midterm.kreosoft.space/api/favorites")
    }
}
