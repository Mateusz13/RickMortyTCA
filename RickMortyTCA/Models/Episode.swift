//
//  Episode.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 02/06/2025.
//

import Foundation

struct Episode: Codable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
}
