//
//  SearchedMovieInfoResponseModel.swift
//  iOS_Practical_Test_Anamul
//
//  Created by Anamul Habib on 10/30/21.
//

import Foundation

// MARK: - SearchedMovieInfoResponseModel
class SearchedMovieInfoResponseModel: Codable {
    let results: [SearchedMovieResult]?

    enum CodingKeys: String, CodingKey {
        case results = "results"
    }

    init(results: [SearchedMovieResult]?) {
        self.results = results
    }
}

// MARK: - Result
class SearchedMovieResult: Codable {
    let id: Int?
    let overview: String?
    let posterPath: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case overview = "overview"
        case posterPath = "poster_path"
        case title = "title"
    }

    init(id: Int?, overview: String?, posterPath: String?, title: String?) {
        self.id = id
        self.overview = overview
        self.posterPath = posterPath
        self.title = title
    }
}
