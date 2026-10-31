//
//  MoviesPagedListModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct MoviesPagedListModel: Codable {
    let movies: [MovieElementModel]?
    let pageInfo: PageInfoModel
}
