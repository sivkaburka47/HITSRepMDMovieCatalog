//
//  FavoriteDeleteAPIEndpoint.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 03.11.2024.
//

import Foundation

struct FavoriteDeleteAPIEndpoint {
    
    static func deleteFavorite(token: String, movieId: String) -> URL? {
        return URL(string: "https://react-midterm.kreosoft.space/api/favorites/\(movieId)/delete")
    }
}
