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

    enum Action {
        case errorOccurred(NetworkServiceErrors)
        case alert(PresentationAction<Alert>)
        
        enum Alert {
            case cancelButtonTapped
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

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
