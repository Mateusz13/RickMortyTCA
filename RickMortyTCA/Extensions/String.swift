//
//  String.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import Foundation

extension String {
    func mapEpisodeURLToNumber() -> String {
        self.replacingOccurrences(of: "https://rickandmortyapi.com/api/episode/", with: "")
    }
}
