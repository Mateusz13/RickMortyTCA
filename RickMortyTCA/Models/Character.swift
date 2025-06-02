//
//  Character.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 02/06/2025.
//

import Foundation

struct Character: Equatable, Identifiable, Codable {
    let id: Int
    let name: String
    let status: String
    let gender: String
    let origin: Origin
    let location: LastKnownLocation
    let image: String
    let episode: [String]

    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
}

struct LastKnownLocation: Equatable, Codable {
    var name: String
}

struct Origin: Equatable, Codable {
    var name: String
}
