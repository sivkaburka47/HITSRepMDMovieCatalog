//
//  MovieRepositoryImpl.swift
//  MDMovieCatalog
//
//  Created by Станислав Дейнекин on 24.10.2024.
//

import Foundation

class MovieRepositoryImpl: MovieRepository {
    
    func fetchMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = MovieAPIEndpoint.getMovies(page: page) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                let movies = movieResponse.movies.map { Movie(from: $0) }
                completion(.success(movies))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchFavorites(token: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = FavoriteAPIEndpoint.getFavorites(token: token) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Требуется повторная авторизация")
                completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let favoriteResponse = try decoder.decode(FavoriteResponse.self, from: data)
                let movies = favoriteResponse.movies.map { Movie(from: $0) }
                completion(.success(movies))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func addFavorite(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = FavoriteAddAPIEndpoint.addFavorite(token: token, movieId: movieId) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Требуется повторная авторизация")
                completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)))
            }
        }
        
        task.resume()
    }
    
    func deleteFavorite(token: String, movieId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = FavoriteDeleteAPIEndpoint.deleteFavorite(token: token, movieId: movieId) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 401 {
                print("Требуется повторная авторизация")
                completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)))
            }
        }
        
        task.resume()
    }
    

}
