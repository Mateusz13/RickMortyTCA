//
//  CharacterDetailsReducer.swift
//  RickMortyTCA
//
//  Created by Mateusz Szafarczyk on 04/06/2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CharacterDetailsReducer {
    @ObservableState
    struct State {
        @Presents var alert: AlertState<Action.Alert>?
        let character: Character
        var isFavorite: Bool
    }
    
    @Dependency(\.coreDataService) var favoriteRepository

    enum Action {
        case errorOccurred(NetworkServiceErrors)
        case alert(PresentationAction<Alert>)
        
        case favoriteButtonTapped
        case favoriteUpdated(Bool)
        
        enum Alert {
            case cancelButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .favoriteButtonTapped:
                let characterID = state.character.id
                let currentlyFavorite = state.isFavorite

                return .run { send in
                    do {
                        if currentlyFavorite {
                            try await self.favoriteRepository.removeFavorite(id: characterID)
                        } else {
                            try await self.favoriteRepository.addFavorite(id: characterID)
                        }
                        //Toggle only after success
                        await send(.favoriteUpdated(!currentlyFavorite))
                    } catch {
                        await send(.errorOccurred(.invalidData))
                    }
                }

            case .favoriteUpdated(let newValue):
                state.isFavorite = newValue
                return .none

            case .errorOccurred(let error):
                state.alert = AlertState {
                    TextState("Error occured!")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState(error.errorDescription ?? "Unknown error")
                }

                return .none
                
            case .alert(.presented(.cancelButtonTapped)):
                state.alert = nil
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
