//
//  FavoriteAddAPIEndpoint.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 31.10.2024.
//

import Foundation

struct FavoriteAddAPIEndpoint {
    
    static func addFavorite(token: String, movieId: String) -> URL? {
        return URL(string: "https://react-midterm.kreosoft.space/api/favorites/\(movieId)/add")
    }
}
