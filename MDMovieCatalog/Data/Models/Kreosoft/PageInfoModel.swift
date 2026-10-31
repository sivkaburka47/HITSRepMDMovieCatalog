//
//  PageInfoModel.swift
//  MDMovieCatalog
//
//  Created by Stanislav Deinekin on 31.10.2026.
//

import Foundation

struct PageInfoModel: Codable {
    let pageSize: Int
    let pageCount: Int
    let currentPage: Int
}
