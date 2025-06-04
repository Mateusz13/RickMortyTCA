//
//  EpisodeDetailsReducer.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EpisodeDetailsReducer {
    @ObservableState
    struct State {
        let episode: Episode
    }

    enum Action: Equatable {
        case closeButtonTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                // Handled by parent reducer
                return .none
            }
        }
    }
}
