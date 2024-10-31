//
//  MovieRepository.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

protocol MovieRepository {
    func fetchMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void)
    func fetchFavorites(token: String, completion: @escaping (Result<[Movie], Error>) -> Void)
    func addFavorite(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void)
}
