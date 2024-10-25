//
//  MovieAPIEndpoint.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

struct MovieAPIEndpoint {
    
    static func getMovies(page: Int) -> URL? {
        return URL(string: "https://react-midterm.kreosoft.space/api/movies/\(page)")
    }
}
